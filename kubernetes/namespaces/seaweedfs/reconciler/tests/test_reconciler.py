"""Unit tests for seaweedfs_reconciler.py (stdlib unittest).

Run: python3 -m unittest discover -s k8s/namespaces/seaweedfs/reconciler/tests
Fixtures are real `volume.list` captures from NL on 2026-09-21 (IFRNLLEI01PRD-2850):
  lowdisk    17:25 NL, volume-0 below the 1 % floor: 1451 read-only replicas, 518 GiB garbage
  recovering 18:2x NL, after the first targeted vacuum batch
"""
import gzip
import os
import sys
import unittest

HERE = os.path.dirname(__file__)
sys.path.insert(0, os.path.join(HERE, ".."))
import seaweedfs_reconciler as r  # noqa: E402

GIB = 1024 ** 3


def fixture(name):
    with gzip.open(os.path.join(HERE, "fixtures", name), "rt") as f:
        return f.read()


LOWDISK = r.parse_volume_list(fixture("volume-list-lowdisk-20260921.txt.gz"))
RECOVERING = r.parse_volume_list(fixture("volume-list-recovering-20260921.txt.gz"))
NODES = sorted({x["node"] for x in LOWDISK})


class Parse(unittest.TestCase):
    def test_real_capture(self):
        self.assertEqual(len(NODES), 2)
        self.assertEqual(len(LOWDISK), 2794)
        self.assertEqual(sum(x["read_only"] for x in LOWDISK), 1451)
        v = [x for x in LOWDISK if x["id"] == 1606]
        self.assertEqual(len(v), 2)
        self.assertEqual(v[0]["collection"], "thanos-nl")
        self.assertGreater(v[0]["deleted"] / v[0]["size"], 0.8)

    def test_default_collection_is_empty_string(self):
        self.assertIn("", {x["collection"] for x in LOWDISK})

    def test_garbage_text_fails_closed(self):
        for text in ("", "error: need to run \"lock\" first to continue\n", "Topology volumeSizeLimit:8000 MB\n"):
            with self.assertRaises(r.ParseError):
                r.parse_volume_list(text)


class Plan(unittest.TestCase):
    def test_digs_out_of_the_real_lockout(self):
        # 17:24 NL: volume-0 had 10.9 GB free and was read-only. Explicit-id vacuum of the
        # high-garbage volumes is exactly what recovered it; the plan must select them,
        # and every selected replica must fit.
        free = {NODES[0]: int(10.9e9), NODES[1]: int(17.0e9)}
        ids, st = r.plan_vacuum(LOWDISK, free, 0.5, 1 * GIB, 500)
        self.assertGreater(len(ids), 100)
        self.assertGreater(st["chosen_garbage"], 150 * GIB)
        by = {}
        for x in LOWDISK:
            by.setdefault(x["id"], []).append(x)
        for vid in ids:
            for rep in by[vid]:
                self.assertLessEqual(rep["size"] + 16 * rep["files"] + GIB, free[rep["node"]])

    def test_largest_garbage_first(self):
        free = {n: 500 * GIB for n in NODES}
        ids, _ = r.plan_vacuum(LOWDISK, free, 0.1, GIB, 500)
        by = {}
        for x in LOWDISK:
            by.setdefault(x["id"], []).append(x)
        g = [sum(x["deleted"] for x in by[v]) for v in ids]
        self.assertEqual(g, sorted(g, reverse=True))

    def test_no_room_is_reported_not_silent(self):
        ids, st = r.plan_vacuum(LOWDISK, {n: 0 for n in NODES}, 0.5, GIB, 500)
        self.assertEqual(ids, [])
        self.assertGreater(st["no_room"], 100)
        self.assertGreater(st["no_room_garbage"], 150 * GIB)

    def test_both_replicas_must_qualify(self):
        reps = [
            {"node": "a", "id": 1, "collection": "c", "size": 100, "files": 1, "deletes": 1, "deleted": 90, "read_only": False},
            {"node": "b", "id": 1, "collection": "c", "size": 100, "files": 1, "deletes": 0, "deleted": 5, "read_only": False},
        ]
        ids, _ = r.plan_vacuum(reps, {"a": 10 ** 9, "b": 10 ** 9}, 0.5, 0, 10)
        self.assertEqual(ids, [])

    def test_unknown_node_free_means_no_room(self):
        reps = [{"node": "x", "id": 7, "collection": "c", "size": 100, "files": 1, "deletes": 1,
                 "deleted": 99, "read_only": True}]
        ids, st = r.plan_vacuum(reps, {}, 0.5, 0, 10)
        self.assertEqual((ids, st["no_room"]), ([], 1))

    def test_cap(self):
        ids, st = r.plan_vacuum(LOWDISK, {n: 500 * GIB for n in NODES}, 0.1, GIB, 7)
        self.assertEqual(len(ids), 7)

    def test_recovered_volume_is_not_chosen_again(self):
        ids, _ = r.plan_vacuum(RECOVERING, {n: 500 * GIB for n in NODES}, 0.1, GIB, 5000)
        self.assertNotIn(1606, ids)


class Effect(unittest.TestCase):
    """A refused vacuum prints nothing and exits 0 (first production run, 2026-09-21: 129
    requests 'processed', 0 compacted). Only the data can tell."""

    def test_silent_refusal_is_zero_effect(self):
        ids = [x["id"] for x in LOWDISK[:50]]
        self.assertEqual(r.vacuum_effect(LOWDISK, LOWDISK, ids), ([], 0))

    def test_real_compaction_is_counted(self):
        # vol 1606 went from ~2.2 GB garbage (lowdisk) to 0 (recovering)
        done, rec = r.vacuum_effect(LOWDISK, RECOVERING, [1606])
        self.assertEqual(done, [1606])
        self.assertGreater(rec, 2 * 10 ** 9)

    def test_only_chosen_ids_are_judged(self):
        done, _ = r.vacuum_effect(LOWDISK, RECOVERING, [])
        self.assertEqual(done, [])


class Output(unittest.TestCase):
    def test_lock_error_with_rc0_is_an_error(self):
        self.assertTrue(r.output_errors('error: need to run "lock" first to continue\n'))

    def test_already_running_is_benign(self):
        self.assertEqual(r.output_errors("Vacuum is already running\n"), [])

    def test_insufficient_space_is_an_error(self):
        self.assertTrue(r.output_errors("volume 12: insufficient free space for compaction\n"))

    def test_timeout_marker_is_an_error(self):
        self.assertTrue(r.output_errors("\nerror: timed out after 900s (weed lock held elsewhere?)\n"))

    def test_clean_transcript(self):
        self.assertEqual(r.output_errors("> lock\n> volume.deleteEmpty -quietFor=24h -apply\n> unlock\n"), [])


class Drift(unittest.TestCase):
    @staticmethod
    def sts(cmd=None, replicas=1):
        return {"spec": {"replicas": replicas, "template": {"spec": {"containers": [{"command": cmd or []}]}}}}

    def test_chart_style_single_shell_string(self):
        cmd = ["/bin/sh", "-ec", "exec /usr/bin/weed -logtostderr=true volume -port=8080 REDACTED_c8e5e375 -dir=/data"]
        self.assertEqual(r.floor_from_command(cmd), 5.0)

    def test_matching_is_clean(self):
        self.assertEqual(r.drift_problems(self.sts(["REDACTED_c8e5e375"]), self.sts(replicas=1), 5.0, 1), [])

    def test_hand_lowered_floor(self):
        p = r.drift_problems(self.sts(["REDACTED_7639e0bd"]), None, 5.0, None)
        self.assertEqual(len(p), 1)
        self.assertIn("Git says 5", p[0])

    def test_scaled_compactor(self):
        p = r.drift_problems(None, self.sts(replicas=0), None, 1)
        self.assertIn("thanos-compactor", p[0])

    def test_missing_floor_flag(self):
        self.assertTrue(r.drift_problems(self.sts(["/usr/bin/weed", "volume"]), None, 5.0, None))

    def test_expected_parked_is_not_drift(self):
        # GR parks its compactor in Git on purpose: live 0 == Git 0
        self.assertEqual(r.drift_problems(None, self.sts(replicas=0), None, 0), [])


if __name__ == "__main__":
    unittest.main()

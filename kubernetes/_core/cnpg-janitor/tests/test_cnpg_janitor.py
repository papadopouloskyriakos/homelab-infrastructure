"""Unit tests for cnpg_janitor.py (stdlib unittest; run: python3 -m unittest discover -s k8s/_core/cnpg-janitor/tests).

The fixtures reproduce the real 2026-09-21 state on notrf01 (IFRNLLEI01PRD-2850)."""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import cnpg_janitor as j  # noqa: E402

NOW = j.parse_ts("2026-09-21T17:00:00Z")
H = 3600


def ts(hours_ago):
    return __import__("time").strftime("%Y-%m-%dT%H:%M:%SZ", __import__("time").gmtime(NOW - hours_ago * H))


def backup(name, phase, hours_ago, ns="omoikane-db", rv="1"):
    return {"metadata": {"namespace": ns, "name": name, "resourceVersion": rv,
                         "creationTimestamp": ts(hours_ago)},
            "status": {"phase": phase} if phase else {}}


def sched(name, cluster, last_hours_ago, ns="omoikane-db", created_hours_ago=800, suspend=False, annotations=None):
    return {"metadata": {"namespace": ns, "name": name, "creationTimestamp": ts(created_hours_ago),
                         "annotations": annotations or {}},
            "spec": {"cluster": {"name": cluster}, "suspend": suspend},
            "status": {} if last_hours_ago is None else {"lastScheduleTime": ts(last_hours_ago)}}


def cluster(name, last_ok_hours_ago, ns="omoikane-db"):
    return {"metadata": {"namespace": ns, "name": name},
            "status": {} if last_ok_hours_ago is None else {"lastSuccessfulBackup": ts(last_ok_hours_ago)}}


class ParseTs(unittest.TestCase):
    def test_utc_not_local(self):
        # 1970-01-01T01:00:00Z is 3600 regardless of the host's TZ (mktime would shift it)
        self.assertEqual(j.parse_ts("1970-01-01T01:00:00Z"), 3600)

    def test_fractional_seconds(self):
        self.assertEqual(j.parse_ts("1970-01-01T00:00:10.123456Z"), 10)

    def test_empty(self):
        self.assertIsNone(j.parse_ts(None))
        self.assertIsNone(j.parse_ts(""))


class SelectStuck(unittest.TestCase):
    def sel(self, *bs):
        return [(n, p) for _, n, p, _, _ in j.select_stuck(list(bs), NOW, 2 * H, 12 * H)]

    def test_the_real_latch_is_released(self):
        # REDACTED_e5294963 sat in walArchivingFailing for 10 days
        self.assertEqual(self.sel(backup("REDACTED_e5294963", "walArchivingFailing", 254)),
                         [("REDACTED_e5294963", "walArchivingFailing")])

    def test_young_latch_is_left_alone(self):
        self.assertEqual(self.sel(backup("b", "walArchivingFailing", 1)), [])

    def test_in_flight_only_after_twelve_hours(self):
        self.assertEqual(self.sel(backup("r1", "running", 1), backup("r2", "started", 11)), [])
        self.assertEqual(self.sel(backup("r3", "running", 13)), [("r3", "running")])
        self.assertEqual(self.sel(backup("p1", "pending", 30)), [("p1", "pending")])

    def test_done_backups_are_never_candidates(self):
        self.assertEqual(self.sel(backup("c", "completed", 500), backup("f", "failed", 500)), [])

    def test_phaseless_new_backup_is_left_alone(self):
        self.assertEqual(self.sel(backup("n", "", 500)), [])


class Freshness(unittest.TestCase):
    def probs(self, scheds, clusters):
        return j.check_freshness(scheds, clusters, NOW, 30)

    def test_healthy(self):
        self.assertEqual(self.probs([sched("d", "c", 14)], [cluster("c", 14)]), [])

    def test_the_real_trap_on_demand_backup_hides_a_dead_schedule(self):
        # 21 Sep: on-demand backups at 18:00 NL made lastSuccessfulBackup fresh, while
        # omoikane-main-daily had not fired since 12 Sep. Must still be STALE.
        p = self.probs([sched("omoikane-main-daily", "omoikane-main", 206)], [cluster("omoikane-main", 1)])
        self.assertEqual(len(p), 1)
        self.assertIn("schedule has not fired", p[0])

    def test_no_successful_backup(self):
        p = self.probs([sched("d", "c", 5)], [cluster("c", 250)])
        self.assertEqual(len(p), 1)
        self.assertIn("no successful backup", p[0])

    def test_never_fired_and_never_succeeded(self):
        self.assertEqual(len(self.probs([sched("d", "c", None)], [cluster("c", None)])), 2)

    def test_suspended_is_skipped(self):
        self.assertEqual(self.probs([sched("d", "c", 500, suspend=True)], [cluster("c", 500)]), [])

    def test_new_schedule_is_not_judged(self):
        self.assertEqual(self.probs([sched("d", "c", None, created_hours_ago=2)], [cluster("c", None)]), [])

    def test_missing_cluster(self):
        p = self.probs([sched("d", "gone", 5)], [])
        self.assertEqual(len(p), 1)
        self.assertIn("does not exist", p[0])

    def test_annotation_widens_the_limit(self):
        s = sched("weekly", "c", 150, annotations={j.MAX_AGE_ANNOTATION: "200"})
        self.assertEqual(self.probs([s], [cluster("c", 150)]), [])

    def test_namespaces_do_not_mix(self):
        # a same-named cluster in another namespace must not satisfy the check
        p = self.probs([sched("d", "c", 5, ns="a")], [cluster("c", 5, ns="b")])
        self.assertIn("does not exist", p[0])


if __name__ == "__main__":
    unittest.main()

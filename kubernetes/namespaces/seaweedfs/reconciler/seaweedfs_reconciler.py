"""SeaweedFS reconciler: the hourly auto-heal loop for the object store (IFRNLLEI01PRD-2850).

nl-s3 filled three times in eight weeks (2052, 2831, 2850), each time because a
reclaimer had stopped. On 2026-09-21 the way out was to vacuum the highest-garbage
volumes by EXPLICIT id: the master's own vacuum walks EVERY volume at ~10 s each
(~1550 volumes = 4+ h per pass, mostly on volumes with no garbage), so it could not
keep up with a burst. Proven on a disposable SeaweedFS 4.44 the same evening:
  - below -minFreeSpacePercent, a sweep DOES compact volumes that are read-only only
    because the disk is low (so this is not the deadlock older notes describe);
  - a sweep SKIPS volumes the master flags read-only (sealed/marked, `AnyReadOnly`),
    an explicit -volumeId does not ("vacuuming read-only volume N on explicit request");
  - a fast writer can overshoot the floor to 100 % full, because the floor is checked
    periodically; then nothing can compact and only freeing a volume by hand helps.
This job reclaims largest-garbage-first every hour, fails loudly in the no-room case,
and gives the reclaim loop the success signal the master's vacuum never had:

  1. vacuum by explicit -volumeId, largest garbage first, only volumes whose .dat+.idx
     (plus a margin of one full volume) fits on EVERY replica's server, time-budgeted;
  2. volume.deleteEmpty -quietFor=24h -apply (frees volume SLOTS);
  3. volume.vacuum.enable (a forgotten `volume.vacuum.disable` heals within the hour);
  4. s3.clean.uploads -timeAgo=24h (abandoned multipart uploads; the chart never ran it);
  5. drift: live volume -minFreeSpacePercent and thanos-compactor replicas must equal
     what Git says (a `kubectl scale` or a hand-edited StatefulSet fails the job).

FAIL CLOSED, BY OUTPUT. `weed shell` exits 0 on command errors (verified 2026-09-21:
`error: need to run "lock" first to continue`, rc 0), so every step's output is parsed.
"Vacuum is already running" is the master's own loop and is benign. A step failing
never skips the others; any failure fails the Job, and the page keys on the CronJob's
last SUCCESSFUL run (REDACTED_875a0962).

Standard library only. Tested by tests/test_reconciler.py (real volume.list captures).
"""
import json
import os
import re
import ssl
import subprocess
import sys
import time
import urllib.error
import urllib.request

GIB = 1024 ** 3
BENIGN = ("vacuum is already running",)
ERROR_PATTERNS = (
    re.compile(r"^\s*error", re.I),
    re.compile(r"need to run \"?lock\"?", re.I),
    re.compile(r"insufficient free space", re.I),
    re.compile(r"\bfailed\b", re.I),
    re.compile(r"no such command|unknown command", re.I),
)
VOL_RE = re.compile(r"volume Id:(\d+), Size:(\d+), ReplicaPlacement:\d+, Collection:([^,]*),.*?"
                    r"FileCount:(\d+), DeleteCount:(\d+), DeletedByteCount:(\d+), ReadOnly:(true|false)")
NODE_RE = re.compile(r"DataNode (\S+)")


class ParseError(Exception):
    pass


def parse_volume_list(text):
    """`volume.list` output -> list of replicas {node,id,collection,size,deleted,files,deletes,read_only}."""
    node, out, nodes = None, [], set()
    for line in text.splitlines():
        m = NODE_RE.search(line)
        if m:
            node = m.group(1)
            nodes.add(node)
            continue
        m = VOL_RE.search(line)
        if m and node:
            vid, size, col, files, deletes, deleted, ro = m.groups()
            out.append({"node": node, "id": int(vid), "collection": col.strip(), "size": int(size),
                        "files": int(files), "deletes": int(deletes), "deleted": int(deleted),
                        "read_only": ro == "true"})
    if not nodes or not out:
        raise ParseError(f"volume.list parsed to {len(nodes)} node(s) and {len(out)} volume(s)")
    return out


def plan_vacuum(replicas, free_by_node, threshold, margin, max_count):
    """Choose volumes to vacuum. Returns (ids, stats). A volume qualifies when EVERY replica's
    garbage ratio >= threshold, and every replica's server has free >= .dat + .idx + margin
    (both replicas compact; SeaweedFS refuses with 'insufficient free space' otherwise)."""
    by_id = {}
    for r in replicas:
        by_id.setdefault(r["id"], []).append(r)
    candidates, no_room = [], []
    for vid, reps in by_id.items():
        if any(r["size"] <= 0 for r in reps):
            continue
        if min(r["deleted"] / r["size"] for r in reps) < threshold:
            continue
        need_ok = all(free_by_node.get(r["node"], 0) >= r["size"] + 16 * r["files"] + margin for r in reps)
        garbage = sum(r["deleted"] for r in reps)
        (candidates if need_ok else no_room).append((garbage, vid))
    candidates.sort(reverse=True)
    chosen = [vid for _, vid in candidates[:max_count]]
    stats = {
        "eligible": len(candidates) + len(no_room),
        "chosen": len(chosen),
        "no_room": len(no_room),
        "chosen_garbage": sum(g for g, v in candidates[:max_count]),
        "no_room_garbage": sum(g for g, _ in no_room),
        "total_garbage": sum(r["deleted"] for r in replicas),
    }
    return chosen, stats


def output_errors(text):
    """Error lines in a weed shell transcript (rc is meaningless: it is 0 on errors)."""
    errs = []
    for line in text.splitlines():
        low = line.lower()
        if any(b in low for b in BENIGN):
            continue
        if any(p.search(line) for p in ERROR_PATTERNS):
            errs.append(line.strip())
    return errs


def floor_from_command(cmd):
    """Extract -minFreeSpacePercent from a container command (list or single shell string)."""
    text = " ".join(cmd) if isinstance(cmd, list) else str(cmd)
    m = re.search(r"-minFreeSpacePercent[= ]([0-9.]+)", text)
    return float(m.group(1)) if m else None


def drift_problems(volume_sts, compactor_sts, expected_floor, expected_compactor):
    probs = []
    if volume_sts is not None and expected_floor is not None:
        live = floor_from_command(volume_sts["spec"]["template"]["spec"]["containers"][0].get("command")
                                  or volume_sts["spec"]["template"]["spec"]["containers"][0].get("args") or [])
        if live is None:
            probs.append("seaweedfs-volume: no -minFreeSpacePercent in the live command")
        elif abs(live - expected_floor) > 1e-9:
            probs.append(f"seaweedfs-volume: live -minFreeSpacePercent={live:g}, Git says {expected_floor:g} "
                         "(hand-edited StatefulSet? change it in terraform.tfvars, never live)")
    if compactor_sts is not None and expected_compactor is not None:
        live = compactor_sts["spec"].get("replicas", 1)
        if live != expected_compactor:
            probs.append(f"thanos-compactor: live replicas={live}, Git says {expected_compactor} "
                         "(kubectl scale? a parked compactor stops Thanos retention)")
    return probs


# --------------------------------------------------------------------------- runtime

class Weed:
    def __init__(self):
        self.bin = os.environ.get("WEED", "/tools/weed")
        self.masters = os.environ["MASTERS"]
        self.filer = os.environ.get("FILER", "")

    def run(self, commands, timeout, lock=True):
        body = "\n".join((["lock"] if lock else []) + commands + (["unlock"] if lock else [])) + "\n"
        argv = [self.bin, "shell", f"-master={self.masters}"] + ([f"-filer={self.filer}"] if self.filer else [])
        try:
            p = subprocess.run(argv, input=body, capture_output=True, text=True, timeout=timeout)
            return p.stdout + p.stderr
        except subprocess.TimeoutExpired as e:
            partial = (e.stdout or "") if isinstance(e.stdout, str) else ""
            return partial + f"\nerror: timed out after {timeout}s (weed lock held elsewhere?)\n"


def server_free(node):
    with urllib.request.urlopen(f"http://{node}/status", timeout=15) as r:
        doc = json.loads(r.read().decode())
    return sum(int(d.get("free", 0)) for d in doc.get("DiskStatuses", []))


def k8s_get(path):
    sa = "/var/run/secrets/kubernetes.io/serviceaccount"
    with open(f"{sa}/token") as f:
        token = f.read().strip()
    ctx = ssl.create_default_context(cafile=f"{sa}/ca.crt")
    req = urllib.request.Request("https://kubernetes.default.svc" + path)
    req.add_header("Authorization", "Bearer " + token)
    try:
        with urllib.request.urlopen(req, context=ctx, timeout=20) as r:
            return json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def drift_step():
    """Live StatefulSets vs the values Git passed in. True when clean."""
    try:
        exp_floor = os.environ.get("EXPECTED_FLOOR")
        exp_comp = os.environ.get("REDACTED_d7471732")
        probs = drift_problems(
            k8s_get("REDACTED_f3655c6b"),
            k8s_get("REDACTED_80619556"),
            float(exp_floor) if exp_floor else None,
            int(exp_comp) if exp_comp else None)
    except (OSError, ValueError, KeyError) as e:
        print(f"reconciler: [drift] FAILED: {e}")
        return False
    for p in probs:
        print(f"reconciler: [drift] {p}")
    if not probs:
        print("reconciler: [drift] ok")
    return not probs


def main():
    t0 = time.time()
    budget = int(os.environ.get("REDACTED_fc48940e", "2400"))
    threshold = float(os.environ.get("GARBAGE_THRESHOLD", "0.10"))
    margin = int(float(os.environ.get("MARGIN_GIB", "8")) * GIB)
    max_count = int(os.environ.get("MAX_VOLUMES_PER_RUN", "200"))
    batch = int(os.environ.get("BATCH", "10"))
    weed = Weed()
    failures = []

    def step(name, commands, timeout, lock=True):
        out = weed.run(commands, timeout, lock=lock)
        errs = output_errors(out)
        print(f"reconciler: [{name}] {'FAILED: ' + ' | '.join(errs[:5]) if errs else 'ok'}")
        if errs:
            failures.append(name)
        return out

    # 1. vacuum by explicit id
    try:
        replicas = parse_volume_list(weed.run(["volume.list"], 300, lock=False))
        nodes = sorted({r["node"] for r in replicas})
        free = {n: server_free(n) for n in nodes}
        chosen, st = plan_vacuum(replicas, free, threshold, margin, max_count)
        print("reconciler: free " + ", ".join(f"{n.split('.')[0]}={free[n] / GIB:.0f}GiB" for n in nodes)
              + f"; garbage {st['total_garbage'] / GIB:.1f}GiB; {st['eligible']} volume(s) >= {threshold:g}, "
              f"{st['chosen']} chosen ({st['chosen_garbage'] / GIB:.1f}GiB), {st['no_room']} without room")
        if st["no_room"] and not st["chosen"]:
            print(f"reconciler: [vacuum] FAILED: {st['no_room']} volume(s) hold {st['no_room_garbage'] / GIB:.1f}GiB "
                  "of garbage but none fits in the free space of its servers: add space or free a volume by hand")
            failures.append("vacuum-no-room")
        done = 0
        for i in range(0, len(chosen), batch):
            if time.time() - t0 > budget:
                print(f"reconciler: [vacuum] time budget reached after {done} volume(s); the next run continues")
                break
            ids = ",".join(str(v) for v in chosen[i:i + batch])
            out = weed.run([f"volume.vacuum -volumeId={ids} -garbageThreshold={threshold}"], 900)
            errs = output_errors(out)
            if errs:
                print(f"reconciler: [vacuum {ids}] FAILED: {' | '.join(errs[:5])}")
                failures.append("vacuum")
                break
            done += len(chosen[i:i + batch])
        print(f"reconciler: [vacuum] {done} volume(s) processed")
    except (ParseError, OSError, ValueError) as e:
        print(f"reconciler: [vacuum] FAILED: {e}")
        failures.append("vacuum")

    # 2-4. housekeeping, each independent
    step("deleteEmpty", ["volume.deleteEmpty -quietFor=24h -apply"], 600)
    if os.environ.get("VACUUM_ENABLE", "1") == "1":
        step("vacuum.enable", ["volume.vacuum.enable"], 120)
    if weed.filer:
        step("clean.uploads", ["s3.clean.uploads -timeAgo=24h"], 600)

    # 5. drift, live vs Git (DRIFT_CHECK=0 only for the disposable drill cluster)
    if os.environ.get("DRIFT_CHECK", "1") == "1":
        if not drift_step():
            failures.append("drift")
    else:
        print("reconciler: [drift] skipped (DRIFT_CHECK=0)")

    print(f"reconciler: {'FAIL: ' + ', '.join(failures) if failures else 'OK'} in {time.time() - t0:.0f}s")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())

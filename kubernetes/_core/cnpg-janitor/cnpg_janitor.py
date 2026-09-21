"""CloudNativePG backup janitor (IFRNLLEI01PRD-2850).

Two jobs, one run, every CNPG cluster on the site:

1. RELEASE latched Backups. CNPG (v1.30, upstream #10385/#10745 open) never moves a
   Backup out of `walArchivingFailing`, and a ScheduledBackup waits forever for any
   child that is not done (`completed`/`failed`). One latched object therefore stops
   every later scheduled backup, and with no new base backup barman retention prunes
   nothing: cnpg-omoikane grew ~7 GB/day on nl-s3 for 10 days and filled it
   (2026-09-21). A Backup in `walArchivingFailing` older than MIN_AGE_SECONDS, or one
   still pending/started/running/finalizing after STUCK_RUNNING_SECONDS, is deleted.
   The phase is re-read and the DELETE carries a resourceVersion precondition, so an
   object that changed since it was listed is never touched. Deleting a Backup object
   destroys no backup data (it is the record of an attempt); `completed` and `failed`
   ones are never candidates.

2. PROVE backups still happen. For every non-suspended ScheduledBackup: the schedule
   must have fired (status.lastScheduleTime) AND its cluster must have a successful
   backup (status.lastSuccessfulBackup) within MAX_AGE_HOURS. Both, because on
   2026-09-21 on-demand backups made lastSuccessfulBackup fresh while the schedule
   itself had not fired since 09-12. Any failure makes the Job fail; the alert keys
   on the CronJob's last SUCCESSFUL run, so a stuck schedule pages.

Standard library only (python:3-alpine, read-only root filesystem).
Tested by tests/test_cnpg_janitor.py against the functions below.
"""
import calendar
import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.request

LATCHED = {"walArchivingFailing"}
IN_FLIGHT = {"pending", "started", "running", "finalizing"}
MAX_AGE_ANNOTATION = "cnpg-janitor.example.net/max-age-hours"


def parse_ts(value):
    """Kubernetes RFC3339 UTC timestamp -> epoch seconds. timegm, never mktime:
    mktime reads the struct as LOCAL time and ages every object by the UTC offset."""
    if not value:
        return None
    value = value.replace("Z", "")
    if "." in value:
        value = value.split(".", 1)[0]
    return calendar.timegm(time.strptime(value, "%Y-%m-%dT%H:%M:%S"))


def select_stuck(backups, now, min_age, stuck_running):
    """Backups that hold CNPG's backup slot for good. Returns (ns, name, phase, rv, age_s)."""
    out = []
    for b in backups:
        meta = b.get("metadata", {})
        phase = (b.get("status") or {}).get("phase") or ""
        created = parse_ts(meta.get("creationTimestamp"))
        if created is None:
            continue
        age = now - created
        if (phase in LATCHED and age > min_age) or (phase in IN_FLIGHT and age > stuck_running):
            out.append((meta.get("namespace"), meta.get("name"), phase, meta.get("resourceVersion"), int(age)))
    return out


def check_freshness(scheduled, clusters, now, max_age_hours):
    """Problems as human-readable strings; an empty list means every schedule is healthy."""
    by_key = {(c["metadata"]["namespace"], c["metadata"]["name"]): c for c in clusters}
    problems = []
    for sb in scheduled:
        meta, spec, status = sb.get("metadata", {}), sb.get("spec", {}), sb.get("status") or {}
        if spec.get("suspend"):
            continue
        ns, name = meta.get("namespace"), meta.get("name")
        limit_h = float((meta.get("annotations") or {}).get(MAX_AGE_ANNOTATION, max_age_hours))
        limit = limit_h * 3600
        created = parse_ts(meta.get("creationTimestamp")) or now
        if now - created < limit:
            continue  # too new to judge
        cluster_name = (spec.get("cluster") or {}).get("name")
        cluster = by_key.get((ns, cluster_name))
        if cluster is None:
            problems.append(f"{ns}/{name}: its cluster {cluster_name!r} does not exist")
            continue
        last_sched = parse_ts(status.get("lastScheduleTime"))
        if last_sched is None or now - last_sched > limit:
            ago = "never" if last_sched is None else f"{(now - last_sched) / 3600:.0f}h ago"
            problems.append(f"{ns}/{name}: schedule has not fired within {limit_h:.0f}h (last: {ago}); "
                            "a Backup that is not done blocks it")
        last_ok = parse_ts((cluster.get("status") or {}).get("lastSuccessfulBackup"))
        if last_ok is None or now - last_ok > limit:
            ago = "never" if last_ok is None else f"{(now - last_ok) / 3600:.0f}h ago"
            problems.append(f"{ns}/{cluster_name}: no successful backup within {limit_h:.0f}h (last: {ago})")
    return problems


class Api:
    SA = "/var/run/secrets/kubernetes.io/serviceaccount"

    def __init__(self):
        with open(f"{self.SA}/token") as f:
            self.token = f.read().strip()
        self.ctx = ssl.create_default_context(cafile=f"{self.SA}/ca.crt")
        self.base = "https://kubernetes.default.svc/apis/postgresql.cnpg.io/v1"

    def call(self, path, method="GET", body=None):
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(self.base + path, data=data, method=method)
        req.add_header("Authorization", "Bearer " + self.token)
        if data is not None:
            req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, context=self.ctx, timeout=30) as resp:
                raw = resp.read().decode()
                return resp.status, (json.loads(raw) if raw.strip() else {})
        except urllib.error.HTTPError as e:
            return e.code, {}

    def items(self, resource):
        status, doc = self.call(f"/{resource}")
        if status != 200:
            raise RuntimeError(f"listing {resource} returned HTTP {status}")
        return doc.get("items", [])


def main():
    min_age = int(os.environ.get("MIN_AGE_SECONDS", "7200"))
    stuck_running = int(os.environ.get("STUCK_RUNNING_SECONDS", "43200"))
    max_age_h = float(os.environ.get("MAX_AGE_HOURS", "30"))
    dry_run = os.environ.get("DRY_RUN", "") == "1"
    api = Api()
    now = time.time()
    failures = 0

    for ns, name, phase, rv, age in select_stuck(api.items("backups"), now, min_age, stuck_running):
        path = f"/namespaces/{ns}/backups/{name}"
        status, fresh = api.call(path)
        if status == 404:
            continue
        if (fresh.get("status") or {}).get("phase") != phase or fresh["metadata"]["resourceVersion"] != rv:
            print(f"cnpg-janitor: {ns}/{name} changed since listing; left alone")
            continue
        print(f"cnpg-janitor: releasing {ns}/{name} ({phase}, {age // 3600}h old): it holds the backup "
              "slot, so no later backup can start. No backup data is deleted.")
        if dry_run:
            continue
        status, _ = api.call(path, method="DELETE", body={
            "kind": "DeleteOptions", "apiVersion": "v1", "preconditions": {"resourceVersion": rv}})
        if status in (200, 202):
            print(f"cnpg-janitor: released {ns}/{name}")
        elif status == 409:
            print(f"cnpg-janitor: {ns}/{name} changed at delete time (409); left alone")
        else:
            print(f"cnpg-janitor: FAILED to release {ns}/{name} (HTTP {status})")
            failures += 1

    problems = check_freshness(api.items("scheduledbackups"), api.items("clusters"), now, max_age_h)
    for p in problems:
        print(f"cnpg-janitor: STALE {p}")
    if failures or problems:
        print(f"cnpg-janitor: FAIL ({failures} release error(s), {len(problems)} stale schedule(s))")
        return 1
    print("cnpg-janitor: OK, every scheduled backup is fresh")
    return 0


if __name__ == "__main__":
    sys.exit(main())

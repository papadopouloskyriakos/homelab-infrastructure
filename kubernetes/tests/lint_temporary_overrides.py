#!/usr/bin/env python3
"""Below-standard settings must carry an expiring override (IFRNLLEI01PRD-2850).

On 2026-09-15 the NL Thanos compactor was parked at 0 replicas "until nl-s3 has room"
and on 2026-09-10 the SeaweedFS floor went 5 -> 3 -> 2 "temporarily". Nobody undid
either: on 2026-09-21 nl-s3 filled a third time. A temporary change now has to say
when it ends, in `temporary_overrides` (terraform.tfvars), and
REDACTED_8e8e28d2 (monitoring/temporary-overrides-alerts.tf) pages the day
after. This lint makes the registration mandatory:

  * a standard-breaking value without a matching override fails;
  * an override dated more than MAX_DAYS ahead fails (that is not temporary);
  * an EXPIRED override only warns: CI must never block a merge in the middle of an
    incident, and the alert is what enforces the date.

Usage: lint_temporary_overrides.py path/to/terraform.tfvars   (exit 1 on violation)
"""
import datetime
import re
import sys

MAX_DAYS = 120
# setting -> (override name that must exist, predicate that says "below standard", why)
STANDARDS = {
    "REDACTED_6930756b": (
        "seaweedfs_floor_lowered", lambda v: float(v) < 5,
        "the SeaweedFS floor is below the 5 % reserve"),
    "REDACTED_bf135212": (
        "REDACTED_51cd6e47", lambda v: int(v) == 0,
        "the Thanos compactor is parked, so no Thanos retention runs"),
}


def scalar(tfvars, key):
    m = re.search(rf"^{re.escape(key)}\s*=\s*\"?([0-9.]+)\"?", tfvars, re.M)
    return m.group(1) if m else None


def overrides(tfvars):
    m = re.search(r"^temporary_overrides\s*=\s*\{(.*?)\}", tfvars, re.M | re.S)
    if not m:
        return None
    body = re.sub(r"#[^\n]*", "", m.group(1))
    return dict(re.findall(r"\"?([A-Za-z0-9_-]+)\"?\s*=\s*\"([^\"]*)\"", body))


def lint(tfvars, today):
    errors, warnings = [], []
    ov = overrides(tfvars)
    if ov is None:
        return ["temporary_overrides is missing (every site must declare it, `{}` when empty)"], []
    for name, date in ov.items():
        try:
            d = datetime.date.fromisoformat(date)
        except ValueError:
            errors.append(f"override {name}: {date!r} is not a YYYY-MM-DD date")
            continue
        if d > today + datetime.timedelta(days=MAX_DAYS):
            errors.append(f"override {name}: {date} is more than {MAX_DAYS} days out; that is not temporary")
        elif d < today:
            warnings.append(f"override {name} EXPIRED on {date}: REDACTED_8e8e28d2 is paging; "
                            "restore the standard value or renew the date deliberately")
    needed = set()
    for key, (name, below, why) in STANDARDS.items():
        v = scalar(tfvars, key)
        if v is not None and below(v):
            needed.add(name)
            if name not in ov:
                errors.append(f"{key} = {v}: {why}. Register it: temporary_overrides = {{ {name} = \"YYYY-MM-DD\" }}")
    for name in ov:
        if name not in needed:
            warnings.append(f"override {name} is registered but nothing is below standard: remove it")
    return errors, warnings


def main(argv):
    text = open(argv[1]).read()
    errors, warnings = lint(text, datetime.date.today())
    for w in warnings:
        print(f"WARNING: {w}")
    for e in errors:
        print(f"ERROR: {e}")
    print("temporary-overrides lint: " + ("FAIL" if errors else "OK"))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

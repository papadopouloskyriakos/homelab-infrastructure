"""Acknowledged-unreachable devices for NL drift-sync. [IFRNLLEI01PRD-2908, ported from GR -2907]

A device that cannot be reached is a FAILURE by default: the drift-sync used to
count a connection error as "in sync", which hid a dead SSH stack on 7 of 9 GR
devices for over a week. The only way to keep an unreachable device from failing
the job is an entry in known-unreachable.txt, with a reason and an expiry date:

    <device> <YYYY-MM-DD expiry> <reason ...>

An expired entry no longer counts, so a forgotten acknowledgment re-raises itself.
"""
from datetime import date
from pathlib import Path

ACK_FILE = Path(__file__).with_name("known-unreachable.txt")


def load_acks(path=ACK_FILE, today=None):
    """Return {device: (expiry, reason)} for entries that have NOT expired."""
    today = today or date.today()
    acks = {}
    if not path.exists():
        return acks
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(None, 2)
        if len(parts) < 3:
            raise ValueError(f"{path.name}: needs '<device> <YYYY-MM-DD> <reason>': {raw!r}")
        device, expiry, reason = parts
        expiry = date.fromisoformat(expiry)
        if expiry >= today:
            acks[device] = (expiry, reason)
    return acks


def report(failures, acks):
    """Print the unreachable section; return the UNacknowledged [(device, error)]."""
    bad = []
    for device, err in failures:
        if device in acks:
            expiry, reason = acks[device]
            print(f"  acknowledged unreachable: {device} (until {expiry}: {reason})")
        else:
            print(f"  UNREACHABLE: {device}: {err[:120]}")
            bad.append((device, err))
    return bad

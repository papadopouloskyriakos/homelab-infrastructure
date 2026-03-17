"""
Shared device connection factory and constants.

Single source of truth for device types, connection parameters,
and Netmiko/NAPALM driver selection. Replaces the copy-pasted
netmiko_type_map and connection setup in 7+ scripts.
"""
import os
import time
from contextlib import contextmanager
from dataclasses import dataclass
from enum import Enum
from typing import Optional

import napalm
from netmiko import ConnectHandler


class DeviceOS(Enum):
    """Cisco OS types mapped to Netmiko and NAPALM driver names."""
    IOS = "ios"
    ASA = "asa"


@dataclass(frozen=True)
class DeviceProfile:
    """Connection profile for a network device."""
    name: str
    device_type: str          # Config dir name: Router, Switch, Firewall, Access-Point
    os: DeviceOS
    fqdn: str

    @property
    def netmiko_type(self) -> str:
        return f"cisco_{self.os.value}"

    @property
    def napalm_driver(self) -> str:
        return self.os.value

    @property
    def config_path(self) -> str:
        return f"network/configs/{self.device_type}/{self.name}"


# Device type → OS mapping (single source of truth)
DEVICE_TYPE_OS = {
    "Firewall": DeviceOS.ASA,
    "Router": DeviceOS.IOS,
    "Switch": DeviceOS.IOS,
    "Access-Point": DeviceOS.IOS,
}

DNS_SUFFIX = "example.net"
DEFAULT_USER = "kyriakosp"
CONNECT_TIMEOUT = 120
READ_TIMEOUT = 120


def REDACTED_52c008dd() -> tuple[str, str]:
    """Return (username, password) from environment."""
    username = os.getenv("CISCO_USER", DEFAULT_USER)
    password = os.getenv("CISCO_PASSWORD")
    if not password:
        raise EnvironmentError("CISCO_PASSWORD environment variable not set")
    return username, password


def build_profile(device_type: str, device_name: str) -> DeviceProfile:
    """Create a DeviceProfile from CI-style type/name args."""
    os_type = DEVICE_TYPE_OS.get(device_type)
    if os_type is None:
        raise ValueError(
            f"Unknown device type: {device_type}. "
            f"Valid: {', '.join(DEVICE_TYPE_OS)}"
        )
    return DeviceProfile(
        name=device_name,
        device_type=device_type,
        os=os_type,
        fqdn=f"{device_name}.{DNS_SUFFIX}",
    )


MAX_RETRIES = 3
RETRY_DELAY = 15  # seconds between retries (router rate-limits rapid SSH connections)


@contextmanager
def netmiko_connection(profile: DeviceProfile, session_log: Optional[str] = None):
    """
    Context manager for Netmiko connections.

    Ensures disconnect on exit (even on exception), replaces the
    bare ConnectHandler/disconnect pattern used everywhere.
    """
    username, password = REDACTED_52c008dd()
    params = {
        "device_type": profile.netmiko_type,
        "host": profile.fqdn,
        "username": username,
        "password": password,
        "timeout": CONNECT_TIMEOUT,
        "fast_cli": False,
        "read_timeout_override": READ_TIMEOUT,
        "use_keys": False,
        "allow_agent": False,
        # Force password-only auth. IOS-XE closes the connection if too many
        # auth methods fail in a single session (pubkey probes + keyboard-
        # interactive with no TTY exhaust the limit before password is tried).
        "conn_timeout": CONNECT_TIMEOUT,
    }
    if session_log:
        params["session_log"] = session_log

    last_err = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            conn = ConnectHandler(**params)
            break
        except Exception as e:
            last_err = e
            if attempt < MAX_RETRIES:
                print(
                    f"   Connection attempt {attempt}/{MAX_RETRIES} failed: {e}. "
                    f"Retrying in {RETRY_DELAY}s..."
                )
                time.sleep(RETRY_DELAY)
            else:
                raise ConnectionError(
                    f"Failed to connect to {profile.fqdn} after {MAX_RETRIES} attempts"
                ) from last_err

    try:
        yield conn
    finally:
        conn.disconnect()


def fetch_running_config(profile: DeviceProfile) -> str:
    """Fetch running-config from device. Single implementation for all scripts."""
    with netmiko_connection(profile) as conn:
        return conn.send_command("show running-config", read_timeout=READ_TIMEOUT)


@contextmanager
def napalm_connection(profile: DeviceProfile):
    """
    Context manager for NAPALM connections.

    For IOS devices, returns a NAPALM device object.
    For ASA devices, falls back to Netmiko directly because NAPALM's
    IOS driver fails on ASA due to prompt detection issues.

    Yields a NAPALM device object (IOS) or a Netmiko connection (ASA).
    """
    username, password = REDACTED_52c008dd()

    if profile.os == DeviceOS.ASA:
        # ASA: NAPALM IOS driver can't handle ASA prompts — use Netmiko
        with netmiko_connection(profile) as conn:
            yield conn
        return

    # IOS/IOS-XE: use NAPALM
    driver = napalm.get_network_driver(profile.napalm_driver)
    optional_args = {
        "transport": "ssh",
        "conn_timeout": CONNECT_TIMEOUT,
        "inline_transfer": True,
    }

    device = None
    last_err = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            device = driver(
                hostname=profile.fqdn,
                username=username,
                password=password,
                optional_args=optional_args,
            )
            device.open()
            break
        except Exception as e:
            last_err = e
            if attempt < MAX_RETRIES:
                print(
                    f"   NAPALM connection attempt {attempt}/{MAX_RETRIES} failed: {e}. "
                    f"Retrying in {RETRY_DELAY}s..."
                )
                time.sleep(RETRY_DELAY)
            else:
                raise ConnectionError(
                    f"Failed NAPALM connection to {profile.fqdn} after {MAX_RETRIES} attempts"
                ) from last_err

    try:
        yield device
    finally:
        device.close()

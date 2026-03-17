"""Tests for lib/devices.py — shared device module."""
import os
import pytest
from lib.devices import (
    DeviceOS,
    DeviceProfile,
    build_profile,
    DEVICE_TYPE_OS,
)


class TestDeviceProfile:
    def test_ios_device(self):
        p = build_profile("Router", "nlrtr01")
        assert p.os == DeviceOS.IOS
        assert p.netmiko_type == "cisco_ios"
        assert p.napalm_driver == "ios"
        assert p.fqdn == "nlrtr01.example.net"
        assert p.config_path == "REDACTED_6b872376"

    def test_asa_device(self):
        p = build_profile("Firewall", "nlfw01")
        assert p.os == DeviceOS.ASA
        assert p.netmiko_type == "cisco_asa"
        assert p.config_path == "REDACTED_0cc48b91nlfw01"

    def test_switch(self):
        p = build_profile("Switch", "nlsw01")
        assert p.os == DeviceOS.IOS

    def test_access_point(self):
        p = build_profile("Access-Point", "nlap01")
        assert p.os == DeviceOS.IOS

    def test_invalid_type_raises(self):
        with pytest.raises(ValueError, match="Unknown device type"):
            build_profile("InvalidType", "test01")

    def test_all_types_have_os(self):
        for dtype in DEVICE_TYPE_OS:
            p = build_profile(dtype, "testdevice")
            assert p.os is not None


class TestCredentials:
    def test_missing_password_raises(self, monkeypatch):
        monkeypatch.delenv("CISCO_PASSWORD", raising=False)
        from lib.devices import REDACTED_52c008dd
        with pytest.raises(EnvironmentError, match="CISCO_PASSWORD"):
            REDACTED_52c008dd()

    def test_credentials_from_env(self, monkeypatch):
        monkeypatch.setenv("CISCO_USER", "testuser")
        monkeypatch.setenv("CISCO_PASSWORD", "testpass")
        from lib.devices import REDACTED_52c008dd
        user, pw = REDACTED_52c008dd()
        assert user == "testuser"
        assert pw == "testpass"

    def test_default_username(self, monkeypatch):
        monkeypatch.delenv("CISCO_USER", raising=False)
        monkeypatch.setenv("CISCO_PASSWORD", "testpass")
        from lib.devices import REDACTED_52c008dd
        user, pw = REDACTED_52c008dd()
        assert user == "kyriakosp"

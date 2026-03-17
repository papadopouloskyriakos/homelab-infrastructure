"""Tests for v2/validate.py — enhanced config validation."""
import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from v2.validate import ConfigValidator


@pytest.fixture
def validator():
    return ConfigValidator("Router", "nlrtr01")


class TestBasicStructure:
    def test_empty_config_fails(self, validator):
        validator._check_basic_structure("")
        assert any("empty" in e.lower() for e in validator.errors)

    def test_tiny_config_fails(self, validator):
        validator._check_basic_structure("line1\nline2\nline3")
        assert any("small" in e.lower() for e in validator.errors)

    def test_valid_config_passes(self, validator, running_config):
        validator._check_basic_structure(running_config)
        assert not validator.errors


class TestDangerousPatterns:
    def test_no_ip_routing_blocked(self, validator):
        validator._check_dangerous_patterns("no ip routing\n")
        assert any("IP routing" in e for e in validator.errors)

    def test_write_erase_blocked(self, validator):
        validator._check_dangerous_patterns("write erase\n")
        assert any("startup configuration" in e for e in validator.errors)

    def test_reload_blocked(self, validator):
        validator._check_dangerous_patterns("reload\n")
        assert any("Reload" in e for e in validator.errors)

    def test_default_interface_blocked(self, validator):
        validator._check_dangerous_patterns("default interface GigabitEthernet0/0\n")
        assert any("Erases" in e for e in validator.errors)

    def test_normal_commands_pass(self, validator):
        validator._check_dangerous_patterns(
            "hostname test\ninterface Gi0/0\n ip address 1.1.1.1 255.255.255.0\n"
        )
        assert not validator.errors
        assert not validator.warnings


class TestInterfaceConsistency:
    def test_duplicate_ip_detected(self, validator):
        config = (
            "interface Gi0/0\n ip address 1.1.1.1 255.255.255.0\n!\n"
            "interface Gi0/1\n ip address 1.1.1.1 255.255.255.0\n"
        )
        validator._check_interface_consistency(config)
        assert any("Duplicate IP" in e for e in validator.errors)

    def test_unique_ips_pass(self, validator):
        config = (
            "interface Gi0/0\n ip address 1.1.1.1 255.255.255.0\n!\n"
            "interface Gi0/1\n ip address 2.2.2.2 255.255.255.0\n"
        )
        validator._check_interface_consistency(config)
        assert not validator.errors


class TestRoutingSanity:
    def test_no_routing_warns(self, validator):
        validator._check_routing_sanity("hostname test\ninterface Gi0/0\n")
        assert any("default route" in w.lower() or "upstream" in w.lower() for w in validator.warnings)

    def test_default_route_passes(self, validator):
        validator._check_routing_sanity("ip route 0.0.0.0 0.0.0.0 10.0.X.X\n")
        assert not any("default route" in w.lower() for w in validator.warnings)

    def test_bgp_without_neighbors_warns(self, validator):
        validator._check_routing_sanity("router bgp 65000\n bgp router-id 1.1.1.1\n")
        assert any("no neighbors" in w.lower() for w in validator.warnings)

    def test_bgp_with_neighbors_passes(self, validator):
        config = "router bgp 65000\n neighbor 10.0.0.1 remote-as 65001\n"
        validator._check_routing_sanity(config)
        assert not any("no neighbors" in w.lower() for w in validator.warnings)


class TestAclLockout:
    def test_vty_acl_without_mgmt_warns(self, validator):
        config = (
            "access-list 99 permit 10.0.0.0 0.0.0.255\n"
            "access-list 99 deny   any\n"
            "line vty 0 4\n"
            " access-class 99 in\n"
        )
        validator._check_acl_lockout(config)
        assert any("management subnet" in w.lower() for w in validator.warnings)

    def test_vty_acl_with_mgmt_passes(self, validator):
        config = (
            "access-list 10 permit 10.0.X.X 0.0.0.255\n"
            "access-list 10 deny   any\n"
            "line vty 0 4\n"
            " access-class 10 in\n"
        )
        validator._check_acl_lockout(config)
        assert not any("management subnet" in w.lower() for w in validator.warnings)

    def test_no_vty_acl_no_warning(self, validator):
        config = "line vty 0 4\n transport input ssh\n"
        validator._check_acl_lockout(config)
        assert not any("management" in w.lower() for w in validator.warnings)


class TestHierconfigParse:
    def test_valid_config_parses(self, validator, running_config):
        validator._check_hierconfig_parse(running_config)
        assert not validator.errors
        assert any("hier_config parsed" in i for i in validator.info)

    def test_empty_config_parses(self, validator):
        validator._check_hierconfig_parse("hostname test\nend")
        assert not validator.errors


class TestFullValidation:
    def test_valid_config_passes(self, validator, running_config):
        validator.validate(running_config)
        exit_code = validator.report()
        assert exit_code == 0

    def test_dangerous_config_fails(self, validator):
        config = "hostname test\nno ip routing\nend"
        validator.validate(config)
        exit_code = validator.report()
        assert exit_code == 1

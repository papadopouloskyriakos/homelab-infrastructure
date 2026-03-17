"""Tests for filter_dynamic_content.py."""
import pytest
from filter_dynamic_content import DynamicContentFilter


@pytest.fixture
def f():
    return DynamicContentFilter()


class TestDynamicLineDetection:
    """Test that dynamic lines are correctly identified."""

    @pytest.mark.parametrize("line", [
        "Building configuration...",
        "Current configuration : 5760 bytes",
        "! Last configuration change at 00:46:47 CET Fri Nov 21 2025 by kyriakosp",
        "Last configuration change at 12:00:00 UTC Mon Jan 1 2024",
        "! NVRAM config last updated at 12:00:00 UTC Mon Jan 1 2024",
        "! Configuration last modified by admin",
        "cryptochecksum:abcdef1234567890",
        "Cryptochecksum: abcdef1234567890",
        "ntp clock-period 36028996",
        "! uptime is 5 days, 3 hours",
    ])
    def test_dynamic_lines_detected(self, f, line):
        assert f.is_dynamic_line(line), f"Should be dynamic: {line!r}"

    @pytest.mark.parametrize("line", [
        "hostname nlrtr01",
        "interface GigabitEthernet0/0/0",
        " ip address 10.0.X.X 255.255.255.0",
        "router bgp 65000",
        "!",
        "",
        " no shutdown",
        "ip route 0.0.0.0 0.0.0.0 10.0.X.X",
        "access-list 10 permit 10.0.X.X 0.0.0.255",
    ])
    def test_static_lines_not_detected(self, f, line):
        assert not f.is_dynamic_line(line), f"Should NOT be dynamic: {line!r}"

    def test_none_is_not_dynamic(self, f):
        assert not f.is_dynamic_line(None)


class TestFilterConfig:
    """Test full config filtering."""

    def test_strips_dynamic_headers(self, f, running_config):
        filtered = f.filter_config(running_config)
        assert "Building configuration" not in filtered
        assert "Current configuration" not in filtered
        assert "Last configuration change" not in filtered
        assert "ntp clock-period" not in filtered

    def test_preserves_static_content(self, f, running_config):
        filtered = f.filter_config(running_config)
        assert "hostname nlrtr01" in filtered
        assert "interface GigabitEthernet0/0/0" in filtered
        assert "ip address 10.0.X.X" in filtered
        assert "router bgp 65000" in filtered

    def test_collapses_multiple_blank_lines(self, f):
        config = "line1\n\n\n\nline2\n\n\nline3"
        filtered = f.filter_config(config)
        assert "\n\n\n" not in filtered
        assert "line1\n\nline2\n\nline3" == filtered

    def test_strips_trailing_whitespace(self, f):
        config = "hostname test   \ninterface Gi0/0  \n no shutdown "
        filtered = f.filter_config(config)
        for line in filtered.splitlines():
            assert line == line.rstrip(), f"Trailing whitespace on: {line!r}"

    def test_removes_leading_trailing_blank_lines(self, f):
        config = "\n\nhostname test\n\n"
        filtered = f.filter_config(config)
        assert not filtered.startswith("\n")
        assert not filtered.endswith("\n")

    def test_empty_input(self, f):
        assert f.filter_config("") == ""
        assert f.filter_config(None) == ""


class TestCompareConfigs:
    """Test config comparison."""

    def test_identical_configs_are_equal(self, f, running_config):
        equal, filtered1, filtered2 = f.compare_configs(running_config, running_config)
        assert equal
        assert filtered1 == filtered2

    def test_dynamic_only_differences_are_equal(self, f):
        config1 = "hostname test\nntp clock-period 111\nend"
        config2 = "hostname test\nntp clock-period 222\nend"
        equal, _, _ = f.compare_configs(config1, config2)
        assert equal, "Configs differing only in dynamic content should be equal"

    def test_real_differences_are_not_equal(self, f, running_config, intended_config):
        equal, _, _ = f.compare_configs(running_config, intended_config)
        assert not equal

    def test_returns_filtered_versions(self, f):
        config = "Building configuration...\nhostname test\nend"
        _, filtered1, filtered2 = f.compare_configs(config, config)
        assert "Building configuration" not in filtered1
        assert "hostname test" in filtered1

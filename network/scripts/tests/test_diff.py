"""Tests for v2/generate_diff.py — hierconfig-based diff generation."""
import pytest
from pathlib import Path

from hier_config import get_hconfig_fast_load, Platform
from filter_dynamic_content import DynamicContentFilter


@pytest.fixture
def content_filter():
    return DynamicContentFilter()


class TestHierconfigRemediation:
    """Test that hier_config generates correct remediation."""

    def test_interface_addition(self, content_filter):
        """New interface in intended should appear in remediation."""
        running = "hostname test\ninterface Gi0/0\n ip address 1.1.1.1 255.255.255.0"
        intended = (
            "hostname test\n"
            "interface Gi0/0\n ip address 1.1.1.1 255.255.255.0\n"
            "interface Gi0/1\n ip address 2.2.2.2 255.255.255.0\n no shutdown"
        )

        running_hc = get_hconfig_fast_load(Platform.CISCO_IOS, running)
        intended_hc = get_hconfig_fast_load(Platform.CISCO_IOS, intended)
        remediation = running_hc.config_to_get_to(intended_hc)
        rem_text = "\n".join(c.cisco_style_text() for c in remediation.all_children())

        assert "interface Gi0/1" in rem_text
        assert "ip address 2.2.2.2" in rem_text
        assert "no shutdown" in rem_text

    def test_interface_removal(self, content_filter):
        """Interface in running but not intended should be negated."""
        running = (
            "hostname test\n"
            "interface Gi0/0\n ip address 1.1.1.1 255.255.255.0\n"
            "interface Gi0/1\n ip address 2.2.2.2 255.255.255.0"
        )
        intended = "hostname test\ninterface Gi0/0\n ip address 1.1.1.1 255.255.255.0"

        running_hc = get_hconfig_fast_load(Platform.CISCO_IOS, running)
        intended_hc = get_hconfig_fast_load(Platform.CISCO_IOS, intended)
        remediation = running_hc.config_to_get_to(intended_hc)
        rem_text = "\n".join(c.cisco_style_text() for c in remediation.all_children())

        assert "no interface Gi0/1" in rem_text

    def test_ip_address_change(self, content_filter):
        """Changed IP should produce correct remediation."""
        running = "interface Gi0/0\n ip address 1.1.1.1 255.255.255.0"
        intended = "interface Gi0/0\n ip address 2.2.2.2 255.255.255.0"

        running_hc = get_hconfig_fast_load(Platform.CISCO_IOS, running)
        intended_hc = get_hconfig_fast_load(Platform.CISCO_IOS, intended)
        remediation = running_hc.config_to_get_to(intended_hc)
        rem_text = "\n".join(c.cisco_style_text() for c in remediation.all_children())

        assert "ip address 2.2.2.2 255.255.255.0" in rem_text

    def test_bgp_neighbor_addition(self, content_filter):
        """Adding BGP neighbor should appear in remediation."""
        running = "router bgp 65000\n neighbor 10.0.0.1 remote-as 65001"
        intended = (
            "router bgp 65000\n"
            " neighbor 10.0.0.1 remote-as 65001\n"
            " neighbor 10.0.0.2 remote-as 65001"
        )

        running_hc = get_hconfig_fast_load(Platform.CISCO_IOS, running)
        intended_hc = get_hconfig_fast_load(Platform.CISCO_IOS, intended)
        remediation = running_hc.config_to_get_to(intended_hc)
        rem_text = "\n".join(c.cisco_style_text() for c in remediation.all_children())

        assert "neighbor 10.0.0.2 remote-as 65001" in rem_text

    def test_identical_configs_no_remediation(self, content_filter):
        """Identical configs should produce zero remediation."""
        config = "hostname test\ninterface Gi0/0\n ip address 1.1.1.1 255.255.255.0"

        running_hc = get_hconfig_fast_load(Platform.CISCO_IOS, config)
        intended_hc = get_hconfig_fast_load(Platform.CISCO_IOS, config)
        remediation = running_hc.config_to_get_to(intended_hc)
        rem_lines = list(remediation.all_children())

        assert len(rem_lines) == 0, "Identical configs should produce no remediation"

    def test_idempotency(self, content_filter):
        """Applying remediation twice should produce zero changes on second run."""
        running = "hostname test\ninterface Gi0/0\n ip address 1.1.1.1 255.255.255.0"
        intended = "hostname test\ninterface Gi0/0\n ip address 2.2.2.2 255.255.255.0"

        running_hc = get_hconfig_fast_load(Platform.CISCO_IOS, running)
        intended_hc = get_hconfig_fast_load(Platform.CISCO_IOS, intended)

        # First remediation
        rem1 = running_hc.config_to_get_to(intended_hc)
        assert len(list(rem1.all_children())) > 0

        # After applying remediation, running == intended, so second remediation is empty
        rem2 = intended_hc.config_to_get_to(intended_hc)
        assert len(list(rem2.all_children())) == 0, "Second remediation should be empty (idempotent)"


class TestDynamicContentFiltering:
    """Test that dynamic content is filtered before diff."""

    def test_timestamp_differences_ignored(self, content_filter):
        """Configs differing only in timestamps should produce no remediation."""
        config1 = (
            "Building configuration...\n"
            "Current configuration : 1000 bytes\n"
            "! Last configuration change at 12:00:00\n"
            "hostname test\n"
            "ntp clock-period 111\n"
            "end"
        )
        config2 = (
            "Building configuration...\n"
            "Current configuration : 2000 bytes\n"
            "! Last configuration change at 15:00:00\n"
            "hostname test\n"
            "ntp clock-period 222\n"
            "end"
        )

        filtered1 = content_filter.filter_config(config1)
        filtered2 = content_filter.filter_config(config2)

        hc1 = get_hconfig_fast_load(Platform.CISCO_IOS, filtered1)
        hc2 = get_hconfig_fast_load(Platform.CISCO_IOS, filtered2)
        remediation = hc1.config_to_get_to(hc2)

        assert len(list(remediation.all_children())) == 0, \
            "Timestamp-only differences should produce no remediation"


class TestFixtureConfigDiff:
    """Test diff with the full fixture configs."""

    def test_fixture_diff_detects_changes(self, running_config, intended_config, content_filter):
        """Fixture configs should produce expected remediation."""
        filtered_running = content_filter.filter_config(running_config)
        filtered_intended = content_filter.filter_config(intended_config)

        running_hc = get_hconfig_fast_load(Platform.CISCO_IOS, filtered_running)
        intended_hc = get_hconfig_fast_load(Platform.CISCO_IOS, filtered_intended)
        remediation = running_hc.config_to_get_to(intended_hc)
        rem_text = "\n".join(c.cisco_style_text() for c in remediation.all_children())

        # Should add new interface
        assert "interface GigabitEthernet0/0/2" in rem_text
        # Should remove old interface
        assert "no interface GigabitEthernet0/0/1" in rem_text
        # Should add new BGP neighbor
        assert "neighbor 10.0.X.X remote-as 65001" in rem_text

    def test_fixture_diff_preserves_unchanged(self, running_config, intended_config, content_filter):
        """Unchanged config should not appear in remediation."""
        filtered_running = content_filter.filter_config(running_config)
        filtered_intended = content_filter.filter_config(intended_config)

        running_hc = get_hconfig_fast_load(Platform.CISCO_IOS, filtered_running)
        intended_hc = get_hconfig_fast_load(Platform.CISCO_IOS, filtered_intended)
        remediation = running_hc.config_to_get_to(intended_hc)
        rem_text = "\n".join(c.cisco_style_text() for c in remediation.all_children())

        # Unchanged interface should not appear
        assert "ip address 10.0.X.X" not in rem_text
        # Unchanged default route should not appear
        assert "ip route 0.0.0.0 0.0.0.0 10.0.X.X" not in rem_text

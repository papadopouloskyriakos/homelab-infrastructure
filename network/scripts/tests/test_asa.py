"""Tests for lib/asa.py — ASA-specific hierconfig support."""
import pytest
import sys
import os
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from lib.asa import (
    strip_asa_dynamic,
    deduplicate_top_level,
    strip_dedup_markers,
    prepare_asa_config,
    get_asa_hconfig,
)
from filter_dynamic_content import DynamicContentFilter

ASA_CONFIG = Path(__file__).resolve().parent.parent.parent / "configs" / "Firewall" / "nlfw01"


@pytest.fixture
def asa_raw():
    if not ASA_CONFIG.exists():
        pytest.skip("ASA config file not available")
    return ASA_CONFIG.read_text()


@pytest.fixture
def content_filter():
    return DynamicContentFilter()


class TestStripAsaDynamic:
    def test_strips_colon_headers(self):
        config = ": Saved\n:\n: Serial Number: ABC\n: Hardware: ASA\nhostname test"
        result = strip_asa_dynamic(config)
        assert ": Saved" not in result
        assert "Serial Number" not in result
        assert "hostname test" in result

    def test_strips_cryptochecksum(self):
        config = "hostname test\nCryptochecksum:abc123\n: end"
        result = strip_asa_dynamic(config)
        assert "Cryptochecksum" not in result
        assert ": end" not in result
        assert "hostname test" in result

    def test_strips_bang_separators(self):
        config = "interface Gi1/1\n shutdown\n!\ninterface Gi1/2\n no shutdown"
        result = strip_asa_dynamic(config)
        assert "!" not in result
        assert "interface Gi1/1" in result
        assert "interface Gi1/2" in result

    def test_preserves_indented_content(self):
        config = "policy-map global\n class inspection_default\n  inspect dns"
        result = strip_asa_dynamic(config)
        assert result == config


class TestDeduplicateTopLevel:
    def test_deduplicates_object_network(self):
        config = "object network FOO\n host 1.1.1.1\nobject network FOO\n nat dynamic PAT"
        result = deduplicate_top_level(config)
        lines = result.splitlines()
        assert lines[0] == "object network FOO"
        assert "{#2}" in lines[2]  # Second occurrence gets marker
        assert lines[1] == " host 1.1.1.1"
        assert lines[3] == " nat dynamic PAT"

    def test_deduplicates_remarks(self):
        config = "access-list X remark [test]\naccess-list X permit ip any any\naccess-list X remark [test]"
        result = deduplicate_top_level(config)
        lines = result.splitlines()
        assert "{#2}" in lines[2]
        assert "{#" not in lines[0]

    def test_no_dedup_for_unique_lines(self):
        config = "hostname test\ninterface Gi0/0\nobject network A\n host 1.1.1.1"
        result = deduplicate_top_level(config)
        assert "{#" not in result

    def test_does_not_dedup_indented_lines(self):
        config = "interface Gi0/0\n no shutdown\ninterface Gi0/1\n no shutdown"
        result = deduplicate_top_level(config)
        assert "{#" not in result  # " no shutdown" is indented, not top-level


class TestStripDedupMarkers:
    def test_strips_markers(self):
        assert strip_dedup_markers("object network FOO {#2}") == "object network FOO"
        assert strip_dedup_markers("remark [test] {#3}") == "remark [test]"

    def test_no_change_without_markers(self):
        assert strip_dedup_markers("hostname test") == "hostname test"


class TestPrepareAsaConfig:
    def test_full_pipeline(self, content_filter):
        config = (
            ": Saved\n"
            ":\n"
            ": Serial Number: ABC\n"
            "Cryptochecksum:abc123\n"
            "!\n"
            "hostname nlfw01\n"
            "!\n"
            "object network FOO\n"
            " host 1.1.1.1\n"
            "object network FOO\n"
            " nat dynamic PAT\n"
            "ntp clock-period 12345\n"
            ": end\n"
        )
        result = prepare_asa_config(config, base_filter=content_filter)
        assert ": Saved" not in result
        assert "Cryptochecksum" not in result
        assert "ntp clock-period" not in result
        assert "!" not in result
        assert "hostname nlfw01" in result
        assert "object network FOO" in result
        # Second occurrence should have dedup marker
        lines = [l for l in result.splitlines() if l.startswith("object network FOO")]
        assert len(lines) == 2
        assert "{#2}" in lines[1]


class TestGetAsaHconfig:
    def test_parses_simple_asa(self, content_filter):
        config = (
            "hostname test\n"
            "interface Gi1/1\n"
            " nameif inside\n"
            " security-level 100\n"
            " ip address 10.0.0.1 255.255.255.0\n"
            "object network MY_NET\n"
            " subnet 10.0.0.0 255.255.255.0\n"
        )
        prepared = prepare_asa_config(config, base_filter=content_filter)
        hc = get_asa_hconfig(prepared)
        children = list(hc.all_children())
        assert len(children) > 0

    def test_parses_real_asa_config(self, asa_raw, content_filter):
        """Parse the real 2031-line nlfw01 config."""
        prepared = prepare_asa_config(asa_raw, base_filter=content_filter)
        hc = get_asa_hconfig(prepared)

        children = list(hc.all_children())
        assert len(children) > 1000, f"Expected >1000 lines, got {len(children)}"

        top = list(hc.children)
        assert len(top) > 500, f"Expected >500 top-level entries, got {len(top)}"

    def test_identical_asa_zero_remediation(self, asa_raw, content_filter):
        """Identical ASA configs should produce zero remediation."""
        prepared = prepare_asa_config(asa_raw, base_filter=content_filter)
        hc1 = get_asa_hconfig(prepared)
        hc2 = get_asa_hconfig(prepared)

        remediation = hc1.config_to_get_to(hc2)
        rem_lines = list(remediation.all_children())
        assert len(rem_lines) == 0, (
            f"Expected 0 remediation lines, got {len(rem_lines)}: "
            + ", ".join(l.cisco_style_text() for l in rem_lines[:5])
        )

    def test_asa_object_network_change(self, content_filter):
        """Changing an object network host should produce correct remediation."""
        running = (
            "hostname test\n"
            "object network MY_HOST\n"
            " host 10.0.0.1\n"
        )
        intended = (
            "hostname test\n"
            "object network MY_HOST\n"
            " host 10.0.0.2\n"
        )
        run_p = prepare_asa_config(running, base_filter=content_filter)
        int_p = prepare_asa_config(intended, base_filter=content_filter)

        hc_run = get_asa_hconfig(run_p)
        hc_int = get_asa_hconfig(int_p)
        remediation = hc_run.config_to_get_to(hc_int)
        rem_text = "\n".join(c.cisco_style_text() for c in remediation.all_children())

        assert "host 10.0.0.2" in rem_text

    def test_asa_acl_change(self, content_filter):
        """Adding an ACL entry should appear in remediation."""
        running = (
            "access-list OUTSIDE extended deny ip any any\n"
        )
        intended = (
            "access-list OUTSIDE extended permit tcp any host 10.0.0.1 eq 443\n"
            "access-list OUTSIDE extended deny ip any any\n"
        )
        run_p = prepare_asa_config(running, base_filter=content_filter)
        int_p = prepare_asa_config(intended, base_filter=content_filter)

        hc_run = get_asa_hconfig(run_p)
        hc_int = get_asa_hconfig(int_p)
        remediation = hc_run.config_to_get_to(hc_int)
        rem_text = "\n".join(c.cisco_style_text() for c in remediation.all_children())

        assert "permit tcp any host 10.0.0.1 eq 443" in rem_text

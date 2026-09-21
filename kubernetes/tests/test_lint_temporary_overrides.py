"""Tests for lint_temporary_overrides.py (run: python3 -m unittest discover -s k8s/tests)."""
import datetime
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import lint_temporary_overrides as L  # noqa: E402

TODAY = datetime.date(2026, 9, 21)


def run(tfvars):
    return L.lint(tfvars, TODAY)


class Lint(unittest.TestCase):
    def test_standard_values_need_nothing(self):
        e, w = run('REDACTED_6930756b = 5\nREDACTED_bf135212 = 1\ntemporary_overrides = {}\n')
        self.assertEqual((e, w), ([], []))

    def test_the_21_sep_park_without_an_expiry_fails(self):
        e, _ = run('REDACTED_bf135212 = 0    # TEMPORARY 2026-09-15: back to 1 once nl-s3 has room\ntemporary_overrides = {}\n')
        self.assertEqual(len(e), 1)
        self.assertIn("REDACTED_51cd6e47", e[0])

    def test_lowered_floor_fails_without_override(self):
        e, _ = run('REDACTED_6930756b = 0.5\ntemporary_overrides = {}\n')
        self.assertIn("seaweedfs_floor_lowered", e[0])

    def test_registered_override_passes(self):
        e, w = run('REDACTED_6930756b = 1\ntemporary_overrides = {\n  seaweedfs_floor_lowered = "2026-09-24" # one vacuum pass\n}\n')
        self.assertEqual((e, w), ([], []))

    def test_expired_override_only_warns(self):
        e, w = run('REDACTED_bf135212 = 0\ntemporary_overrides = { "REDACTED_51cd6e47" = "2026-09-01" }\n')
        self.assertEqual(e, [])
        self.assertIn("EXPIRED", w[0])

    def test_far_future_is_not_temporary(self):
        e, _ = run('REDACTED_bf135212 = 0\ntemporary_overrides = { REDACTED_51cd6e47 = "2027-06-01" }\n')
        self.assertIn("not temporary", e[0])

    def test_bad_date(self):
        e, _ = run('temporary_overrides = { x = "soon" }\n')
        self.assertIn("not a YYYY-MM-DD", e[0])

    def test_stale_override_warns(self):
        e, w = run('REDACTED_bf135212 = 1\ntemporary_overrides = { REDACTED_51cd6e47 = "2026-10-01" }\n')
        self.assertEqual(e, [])
        self.assertIn("remove it", w[0])

    def test_missing_key_fails(self):
        e, _ = run('REDACTED_bf135212 = 1\n')
        self.assertIn("missing", e[0])

    def test_real_site_files_pass(self):
        # every repo's tfvars must pass as committed (run from the k8s/ dir in CI)
        p = os.path.join(os.path.dirname(__file__), "..", "terraform.tfvars")
        if os.path.exists(p):
            e, _ = L.lint(open(p).read(), datetime.date.today())
            self.assertEqual(e, [], e)


if __name__ == "__main__":
    unittest.main()

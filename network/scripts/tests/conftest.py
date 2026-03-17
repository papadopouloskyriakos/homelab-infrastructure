"""Shared fixtures for network script tests."""
import os
import sys
from pathlib import Path

import pytest

# Ensure scripts directory is importable
SCRIPTS_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(SCRIPTS_DIR))

FIXTURES_DIR = Path(__file__).resolve().parent / "fixtures"


@pytest.fixture
def running_config():
    """Load the test running config fixture."""
    return (FIXTURES_DIR / "router_running.cfg").read_text()


@pytest.fixture
def intended_config():
    """Load the test intended config fixture."""
    return (FIXTURES_DIR / "router_intended.cfg").read_text()


@pytest.fixture
def fixtures_dir():
    """Path to fixtures directory."""
    return FIXTURES_DIR

"""
Tests for pyndschooldata Python wrapper.

Minimal smoke tests - the actual data logic is tested by R testthat.
These just verify the Python wrapper imports and exposes expected functions.
"""

import pytest


def test_import_package():
    """Package imports successfully."""
    import pyndschooldata
    assert pyndschooldata is not None


def test_has_fetch_enr():
    """fetch_enr function is available."""
    import pyndschooldata
    assert hasattr(pyndschooldata, 'fetch_enr')
    assert callable(pyndschooldata.fetch_enr)


def test_has_get_available_years():
    """get_available_years function is available."""
    import pyndschooldata
    assert hasattr(pyndschooldata, 'get_available_years')
    assert callable(pyndschooldata.get_available_years)


def test_has_version():
    """Package has a version string."""
    import pyndschooldata
    assert hasattr(pyndschooldata, '__version__')
    assert isinstance(pyndschooldata.__version__, str)


def test_has_fetch_graduation():
    """fetch_graduation function is available."""
    import pyndschooldata
    assert hasattr(pyndschooldata, 'fetch_graduation')
    assert callable(pyndschooldata.fetch_graduation)

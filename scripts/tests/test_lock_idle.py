from __future__ import annotations
from unittest.mock import patch
from timefocus import is_locked, idle_seconds, _parse_ioreg_idle_ns

def test_is_locked_true_when_session_dict_has_lock_flag():
    with patch("timefocus._cgsession_dict",
               return_value={"CGSSessionScreenIsLocked": True}):
        assert is_locked() is True

def test_is_locked_false_when_no_lock_flag():
    with patch("timefocus._cgsession_dict",
               return_value={"CGSSessionScreenIsLocked": False}):
        assert is_locked() is False

def test_is_locked_false_when_dict_missing():
    with patch("timefocus._cgsession_dict", return_value=None):
        assert is_locked() is False

def test_parse_ioreg_idle_ns():
    sample = '"HIDIdleTime" = 4500000000\nfoo'
    assert _parse_ioreg_idle_ns(sample) == 4_500_000_000

def test_parse_ioreg_idle_ns_missing_returns_zero():
    assert _parse_ioreg_idle_ns("nothing here") == 0

def test_idle_seconds_converts_ns_to_seconds():
    with patch("timefocus._ioreg_hid_idle_ns", return_value=12_000_000_000):
        assert idle_seconds() == 12

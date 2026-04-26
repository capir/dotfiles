from __future__ import annotations
from unittest.mock import patch
from timefocus import is_locked

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

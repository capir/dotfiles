from __future__ import annotations
from timefocus import compute_desired, Config, State

CFG = Config(idle_threshold_s=300)

def test_locked_yields_paused():
    d = compute_desired(CFG, State(current_uuid="x"), locked=True, idle_s=0,
                        focus_uuid="y")
    assert d == ("PAUSED", None)

def test_idle_over_threshold_yields_paused():
    d = compute_desired(CFG, State(current_uuid="x"), locked=False, idle_s=400,
                        focus_uuid="y")
    assert d == ("PAUSED", None)

def test_focus_yields_active_with_uuid():
    d = compute_desired(CFG, State(), locked=False, idle_s=0, focus_uuid="y")
    assert d == ("ACTIVE", "y")

def test_no_focus_keeps_current_when_active():
    d = compute_desired(CFG, State(current_uuid="x"), locked=False, idle_s=0,
                        focus_uuid=None)
    assert d == ("ACTIVE", "x")

def test_no_focus_when_paused_stays_paused():
    d = compute_desired(CFG, State(), locked=False, idle_s=0, focus_uuid=None)
    assert d == ("PAUSED", None)

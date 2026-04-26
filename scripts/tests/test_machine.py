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

from timefocus import transition, Action

def test_transition_no_change_yields_noop():
    a = transition(CFG, State(current_uuid="x"), desired=("ACTIVE", "x"), now_iso="t1")
    assert a.kind == "NOOP"

def test_transition_paused_to_active_starts_immediately():
    a = transition(CFG, State(), desired=("ACTIVE", "y"), now_iso="t1")
    assert a.kind == "START"
    assert a.target_uuid == "y"
    assert a.new_state.current_uuid == "y"

def test_transition_active_to_paused_stops_immediately():
    a = transition(CFG, State(current_uuid="x"), desired=("PAUSED", None), now_iso="t1")
    assert a.kind == "STOP"
    assert a.new_state.current_uuid is None

def test_switch_pending_first_seen():
    cfg = Config(switch_debounce_s=30)
    s = State(current_uuid="x", current_since="t0")
    a = transition(cfg, s, desired=("ACTIVE", "y"), now_iso="2026-04-26T08:00:00+00:00")
    assert a.kind == "NOOP"
    assert a.new_state.pending_target == "y"
    assert a.new_state.pending_since == "2026-04-26T08:00:00+00:00"

def test_switch_pending_commits_after_debounce():
    cfg = Config(switch_debounce_s=30)
    s = State(current_uuid="x", current_since="t0",
              pending_target="y", pending_since="2026-04-26T08:00:00+00:00")
    a = transition(cfg, s, desired=("ACTIVE", "y"), now_iso="2026-04-26T08:00:31+00:00")
    assert a.kind == "SWITCH"
    assert a.target_uuid == "y"
    assert a.new_state.current_uuid == "y"
    assert a.new_state.pending_target is None

def test_pending_target_changes_resets_debounce():
    cfg = Config(switch_debounce_s=30)
    s = State(current_uuid="x", pending_target="y", pending_since="2026-04-26T08:00:00+00:00")
    a = transition(cfg, s, desired=("ACTIVE", "z"), now_iso="2026-04-26T08:00:10+00:00")
    assert a.kind == "NOOP"
    assert a.new_state.pending_target == "z"
    assert a.new_state.pending_since == "2026-04-26T08:00:10+00:00"

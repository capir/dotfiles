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

def test_returning_to_current_clears_pending():
    """Invariant: NOOP same-target must wipe stale pending fields."""
    cfg = Config(switch_debounce_s=30)
    s = State(current_uuid="x", current_since="t0",
              pending_target="y", pending_since="2026-04-26T08:00:00+00:00")
    a = transition(cfg, s, desired=("ACTIVE", "x"), now_iso="2026-04-26T08:00:10+00:00")
    assert a.kind == "NOOP"
    assert a.new_state.pending_target is None
    assert a.new_state.pending_since is None

def test_idle_at_threshold_keeps_active_strict_greater():
    """idle_s == idle_threshold_s is NOT idle (strict greater-than). Pin behavior."""
    cfg = Config(idle_threshold_s=300)
    d = compute_desired(cfg, State(current_uuid="x"), locked=False, idle_s=300,
                        focus_uuid="y")
    assert d == ("ACTIVE", "y")
    # one tick later, threshold breached
    d = compute_desired(cfg, State(current_uuid="x"), locked=False, idle_s=301,
                        focus_uuid="y")
    assert d == ("PAUSED", None)

from unittest.mock import patch, call
from pathlib import Path
from timefocus import apply_action, tick_once

def test_apply_action_start_calls_task_start():
    with patch("timefocus._task_cmd") as m:
        a = Action("START", "uuid-y", State(current_uuid="uuid-y"))
        apply_action(a, dry_run=False)
        m.assert_called_once_with(["task", "uuid-y", "start"])

def test_apply_action_switch_stops_then_starts():
    with patch("timefocus._task_cmd") as m:
        a = Action("SWITCH", "uuid-y", State(current_uuid="uuid-y"))
        apply_action(a, dry_run=False, prev_uuid="uuid-x")
        assert m.call_args_list == [
            call(["task", "uuid-x", "stop"]),
            call(["task", "uuid-y", "start"]),
        ]

def test_apply_action_dry_run_does_not_call():
    with patch("timefocus._task_cmd") as m:
        apply_action(Action("START", "y", State()), dry_run=True)
        m.assert_not_called()

def test_tick_once_paused_to_active(tmp_path):
    cfg = Config(worktree_roots=[str(tmp_path)])
    state_path = tmp_path / "s.json"
    log_path = tmp_path / "log.jsonl"
    cache_path = tmp_path / "wt.json"
    with patch("timefocus.is_locked", return_value=False), \
         patch("timefocus.idle_seconds", return_value=0), \
         patch("timefocus.resolve_focus", return_value=tmp_path), \
         patch("timefocus.map_worktree_to_task", return_value="uuid-1"), \
         patch("timefocus._task_cmd"):
        tick_once(cfg, state_path=state_path, log_path=log_path,
                  cache_path=cache_path, dry_run=False)
    from timefocus import load_state
    assert load_state(state_path).current_uuid == "uuid-1"

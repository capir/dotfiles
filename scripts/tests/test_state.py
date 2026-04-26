from __future__ import annotations
from pathlib import Path
from timefocus import State, load_state, save_state

def test_load_state_returns_paused_when_missing(tmp_path):
    s = load_state(tmp_path / "missing.json")
    assert s.current_uuid is None
    assert s.pending_target is None

def test_save_then_load_roundtrip(tmp_path):
    p = tmp_path / "s.json"
    s = State(current_uuid="abc", current_since="2026-04-26T08:00Z",
              pending_target="def", pending_since="2026-04-26T08:01Z")
    save_state(p, s)
    s2 = load_state(p)
    assert s2.current_uuid == "abc"
    assert s2.pending_target == "def"

def test_corrupt_state_is_recovered(tmp_path):
    p = tmp_path / "s.json"
    p.write_text("not json {")
    s = load_state(p)
    assert s.current_uuid is None
    # original renamed
    assert any(q.name.startswith("s.json.broken-") for q in tmp_path.iterdir())

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

import json
from timefocus import log_decision

def test_log_decision_appends_jsonl(tmp_path):
    p = tmp_path / "log.jsonl"
    log_decision(p, {"t": "now", "action": "noop"})
    log_decision(p, {"t": "later", "action": "start"})
    lines = p.read_text().strip().splitlines()
    assert len(lines) == 2
    assert json.loads(lines[0])["action"] == "noop"
    assert json.loads(lines[1])["action"] == "start"

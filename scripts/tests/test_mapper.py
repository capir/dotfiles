from __future__ import annotations
import json
from unittest.mock import patch
from timefocus import task_lookup_by_ticket

def test_task_lookup_returns_uuid_for_single_match():
    out = json.dumps([{"uuid": "abc-123", "status": "pending", "entry": "20260420T000000Z",
                       "linearurl": "https://linear.app/tos/issue/TOS-9/foo"}])
    with patch("timefocus._task_export", return_value=out):
        assert task_lookup_by_ticket("TOS-9") == "abc-123"

def test_task_lookup_picks_newest_pending():
    out = json.dumps([
        {"uuid": "old", "status": "pending", "entry": "20260101T000000Z",
         "linearurl": "https://linear.app/tos/issue/TOS-9/x"},
        {"uuid": "new", "status": "pending", "entry": "20260420T000000Z",
         "linearurl": "https://linear.app/tos/issue/TOS-9/y"},
        {"uuid": "done", "status": "completed", "entry": "20260425T000000Z",
         "linearurl": "https://linear.app/tos/issue/TOS-9/z"},
    ])
    with patch("timefocus._task_export", return_value=out):
        assert task_lookup_by_ticket("TOS-9") == "new"

def test_task_lookup_returns_none_when_no_match():
    with patch("timefocus._task_export", return_value="[]"):
        assert task_lookup_by_ticket("TOS-9") is None

from timefocus import WorktreeCache

def test_cache_get_set_roundtrip(tmp_path):
    c = WorktreeCache(tmp_path / "c.json")
    c.put("/a/b", branch="catalin/tos-9-x", ticket="TOS-9", uuid="u1")
    c2 = WorktreeCache(tmp_path / "c.json")
    e = c2.get("/a/b")
    assert e is not None
    assert e["uuid"] == "u1"
    assert e["branch"] == "catalin/tos-9-x"

def test_cache_invalidates_on_branch_change(tmp_path):
    c = WorktreeCache(tmp_path / "c.json")
    c.put("/a/b", branch="b1", ticket="T-1", uuid="u1")
    assert c.get("/a/b", current_branch="b2") is None
    assert c.get("/a/b", current_branch="b1") is not None

def test_cache_corrupt_file_starts_empty(tmp_path):
    p = tmp_path / "c.json"
    p.write_text("not json {")
    c = WorktreeCache(p)
    assert c.get("/a") is None

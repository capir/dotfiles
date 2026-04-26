from __future__ import annotations

import time, os, json
from pathlib import Path
from timefocus import claude_signal, Config, is_worktree

def _write_session(d: Path, cwd: str, mtime: float | None = None):
    d.mkdir(parents=True, exist_ok=True)
    f = d / "s1.jsonl"
    f.write_text(json.dumps({"type": "x", "cwd": cwd}) + "\n")
    if mtime is not None:
        os.utime(f, (mtime, mtime))

def test_claude_signal_returns_most_recent_session_cwd(tmp_path):
    cfg = Config(claude_session_stale_s=90)
    projects = tmp_path / "projects"
    now = time.time()
    _write_session(projects / "-Users-c-work-old", cwd="/work/old", mtime=now - 600)
    _write_session(projects / "-Users-c-work-new", cwd="/work/new", mtime=now - 5)
    assert str(claude_signal(cfg, projects_root=projects)) == "/work/new"

def test_claude_signal_returns_none_when_stale(tmp_path):
    cfg = Config(claude_session_stale_s=10)
    projects = tmp_path / "projects"
    _write_session(projects / "-foo", cwd="/foo", mtime=time.time() - 60)
    assert claude_signal(cfg, projects_root=projects) is None

def test_claude_signal_falls_back_to_dir_decode_when_no_cwd(tmp_path):
    cfg = Config(claude_session_stale_s=90)
    projects = tmp_path / "projects"
    d = projects / "-tmp-fake-path"
    d.mkdir(parents=True)
    (d / "s.jsonl").write_text('{"type":"x"}\n')  # no cwd field
    result = claude_signal(cfg, projects_root=projects)
    assert str(result) == "/tmp/fake/path"

def test_claude_signal_finds_cwd_in_nested_uuid_subdir(tmp_path):
    cfg = Config(claude_session_stale_s=90)
    projects = tmp_path / "projects"
    proj = projects / "-Users-c-some-project"
    nested = proj / "abc-uuid-subdir"
    nested.mkdir(parents=True)
    f = nested / "session.jsonl"
    f.write_text(json.dumps({"type":"x","cwd":"/some/project"}) + "\n")
    os.utime(f, (time.time() - 5, time.time() - 5))
    assert str(claude_signal(cfg, projects_root=projects)) == "/some/project"

def test_is_worktree_under_root(tmp_path):
    root = tmp_path / "code_base_api_bare"
    wt = root / "toco"
    wt.mkdir(parents=True)
    (wt / ".git").write_text("gitdir: ...")  # git worktree marker
    cfg = Config(worktree_roots=[str(root)])
    assert is_worktree(wt, cfg) is True

def test_is_worktree_has_git_but_outside_root_returns_false(tmp_path):
    other = tmp_path / "elsewhere"
    other.mkdir()
    (other / ".git").write_text("gitdir: ...")
    cfg = Config(worktree_roots=[str(tmp_path / "configured_root")])
    assert is_worktree(other, cfg) is False

def test_is_worktree_canonical_git_dir(tmp_path):
    root = tmp_path / "r"
    wt = root / "repo"
    (wt / ".git").mkdir(parents=True)
    cfg = Config(worktree_roots=[str(root)])
    assert is_worktree(wt, cfg) is True

def test_is_worktree_no_git_returns_false(tmp_path):
    root = tmp_path / "root"
    wt = root / "child"
    wt.mkdir(parents=True)
    cfg = Config(worktree_roots=[str(root)])
    assert is_worktree(wt, cfg) is False

import time
import os
from pathlib import Path
from timefocus import claude_signal, Config

def test_claude_signal_returns_most_recent_session_dir(tmp_path):
    cfg = Config(claude_session_stale_s=90)
    projects = tmp_path / "projects"
    old = projects / "-Users-c-work-TOS-code-base-api-bare-master"
    new = projects / "-Users-c-work-TOS-code-base-api-bare-toco"
    old.mkdir(parents=True)
    new.mkdir(parents=True)
    (old / "s1.jsonl").write_text("{}")
    (new / "s1.jsonl").write_text("{}")
    now = time.time()
    os.utime(old / "s1.jsonl", (now - 600, now - 600))
    os.utime(new / "s1.jsonl", (now - 5, now - 5))
    result = claude_signal(cfg, projects_root=projects)
    assert str(result) == "/Users/c/work/TOS/code_base_api_bare/toco"

def test_claude_signal_returns_none_when_stale(tmp_path):
    cfg = Config(claude_session_stale_s=10)
    projects = tmp_path / "projects"
    d = projects / "-Users-c-foo"
    d.mkdir(parents=True)
    f = d / "s.jsonl"
    f.write_text("{}")
    os.utime(f, (time.time() - 60, time.time() - 60))
    assert claude_signal(cfg, projects_root=projects) is None

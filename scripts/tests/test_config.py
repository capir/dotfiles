import pathlib, textwrap
from timefocus import load_config, Config

def test_load_config_returns_defaults_when_no_file(tmp_path):
    cfg = load_config(tmp_path / "missing.toml")
    assert isinstance(cfg, Config)
    assert cfg.poll_interval_s == 5
    assert cfg.idle_threshold_s == 300
    assert cfg.switch_debounce_s == 30
    assert cfg.min_chunk_s == 30
    assert cfg.claude_session_stale_s == 90
    assert cfg.worktree_roots == []
    assert cfg.ticket_regex == r"(?i)\b(tos|toss)-(\d+)\b"
    assert cfg.bugwarrior_pull_throttle_s == 3600
    assert cfg.fallback_uuid_filename == ".task-uuid"
    assert cfg.log_level == "info"

def test_load_config_overrides_from_toml(tmp_path):
    p = tmp_path / "cfg.toml"
    p.write_text(textwrap.dedent("""
        poll_interval_s = 10
        idle_threshold_s = 600
        worktree_roots = ["/Users/c/work/TOS/code_base_api_bare"]
        log_level = "debug"
    """))
    cfg = load_config(p)
    assert cfg.poll_interval_s == 10
    assert cfg.idle_threshold_s == 600
    assert cfg.worktree_roots == ["/Users/c/work/TOS/code_base_api_bare"]
    assert cfg.log_level == "debug"
    # untouched defaults preserved
    assert cfg.switch_debounce_s == 30

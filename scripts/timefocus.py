#!/usr/bin/env python3
"""timefocus — auto-track focus to taskwarrior/timewarrior."""
from __future__ import annotations

__version__ = "0.1.0"

import re
import tomllib
from dataclasses import dataclass, field
from pathlib import Path

DEFAULT_CONFIG_PATH = Path.home() / ".config" / "timefocus" / "config.toml"

TICKET_RE = re.compile(r"(?i)\b(tos|toss)-(\d+)\b")

def parse_ticket(branch: str) -> str | None:
    m = TICKET_RE.search(branch or "")
    if not m:
        return None
    return f"{m.group(1).upper()}-{m.group(2)}"

@dataclass
class Config:
    poll_interval_s: int = 5
    idle_threshold_s: int = 300
    switch_debounce_s: int = 30
    min_chunk_s: int = 30
    claude_session_stale_s: int = 90
    worktree_roots: list[str] = field(default_factory=list)
    ticket_regex: str = r"(?i)\b(tos|toss)-(\d+)\b"
    linear_url_match: str = "/{ticket}/"
    bugwarrior_pull_throttle_s: int = 3600
    fallback_uuid_filename: str = ".task-uuid"
    log_level: str = "info"

def load_config(path: Path = DEFAULT_CONFIG_PATH) -> Config:
    cfg = Config()
    if not path.exists():
        return cfg
    with path.open("rb") as f:
        data = tomllib.load(f)
    for k, v in data.items():
        if hasattr(cfg, k):
            setattr(cfg, k, v)
    return cfg

def main(argv: list[str] | None = None) -> int:
    import sys
    argv = sys.argv[1:] if argv is None else argv
    if argv == ["--version"]:
        print(__version__)
        return 0
    print("timefocus: not yet implemented", file=sys.stderr)
    return 2

if __name__ == "__main__":
    raise SystemExit(main())

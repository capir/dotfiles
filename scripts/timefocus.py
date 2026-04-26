#!/usr/bin/env python3
"""timefocus — auto-track focus to taskwarrior/timewarrior."""
from __future__ import annotations

__version__ = "0.1.0"

import json as _json
import re
import subprocess
import time
import tomllib
from dataclasses import dataclass, field
from pathlib import Path

DEFAULT_CONFIG_PATH = Path.home() / ".config" / "timefocus" / "config.toml"
CLAUDE_PROJECTS_ROOT = Path.home() / ".claude" / "projects"

TICKET_RE = re.compile(r"(?i)\b(tos|toss)-(\d+)\b")

def parse_ticket(branch: str) -> str | None:
    m = TICKET_RE.search(branch or "")
    if not m:
        return None
    return f"{m.group(1).upper()}-{m.group(2)}"

def is_worktree(path: Path | None, cfg: "Config") -> bool:
    if path is None:
        return False
    try:
        path = path.resolve()
    except OSError:
        return False
    if not (path / ".git").exists():
        return False
    for root in cfg.worktree_roots:
        try:
            path.relative_to(Path(root).resolve())
            return True
        except ValueError:
            continue
    return False

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

def decode_claude_session_dir(name: str) -> Path | None:
    """Decode a Claude projects session directory name back to a filesystem path.

    Claude encodes the project path by replacing slashes with dashes.
    We reconstruct the real path by greedily matching tokens against the
    actual filesystem, so path components containing dashes (e.g. ``geo-photos``)
    are correctly distinguished from path separators.
    """
    if not name.startswith("-"):
        return None
    tokens = name[1:].split("-")
    current = Path("/")
    i = 0
    while i < len(tokens):
        # Try to consume as many tokens as possible that form a real entry name.
        # Prefer longer matches (more dashes consumed) over shorter ones.
        matched: Path | None = None
        match_end = i
        for j in range(len(tokens), i, -1):
            candidate = "_".join(tokens[i:j])  # first try with underscores (unlikely)
            if (current / candidate).exists():
                matched = current / candidate
                match_end = j
                break
            candidate = "-".join(tokens[i:j])  # try with dashes preserved
            if (current / candidate).exists():
                matched = current / candidate
                match_end = j
                break
        if matched is None:
            # Fallback: treat each token as one path component
            current = current / tokens[i]
            i += 1
        else:
            current = matched
            i = match_end
    return current

def _newest_jsonl(d: Path) -> tuple[Path | None, float]:
    """Recursively find the most-recently-modified .jsonl under d.
    Returns (path, mtime) or (None, 0.0)."""
    best, best_m = None, 0.0
    try:
        for p in d.rglob("*.jsonl"):
            try:
                m = p.stat().st_mtime
                if m > best_m:
                    best_m, best = m, p
            except OSError:
                continue
    except OSError:
        pass
    return best, best_m

def _latest_jsonl_mtime(d: Path) -> float:
    """Return mtime of the most-recently-modified .jsonl under d, recursively."""
    return _newest_jsonl(d)[1]

def _read_cwd_from_session_dir(d: Path) -> Path | None:
    """Walk session JSONLs in d (newest first) until one yields a cwd."""
    paths: list[tuple[float, Path]] = []
    try:
        for p in d.rglob("*.jsonl"):
            try:
                paths.append((p.stat().st_mtime, p))
            except OSError:
                continue
    except OSError:
        return None
    paths.sort(reverse=True)
    for _, path in paths:
        try:
            with path.open() as f:
                for line in f:
                    try:
                        rec = _json.loads(line)
                    except _json.JSONDecodeError:
                        continue
                    cwd = rec.get("cwd")
                    if cwd:
                        return Path(cwd)
        except OSError:
            continue
    return None

def claude_signal(cfg: Config, projects_root: Path = CLAUDE_PROJECTS_ROOT) -> Path | None:
    if not projects_root.exists():
        return None
    best_dir, best_mtime = None, 0.0
    for entry in projects_root.iterdir():
        if not entry.is_dir():
            continue
        m = _latest_jsonl_mtime(entry)
        if m > best_mtime:
            best_mtime, best_dir = m, entry
    if best_dir is None:
        return None
    if time.time() - best_mtime > cfg.claude_session_stale_s:
        return None
    cwd = _read_cwd_from_session_dir(best_dir)
    if cwd is not None:
        return cwd
    return decode_claude_session_dir(best_dir.name)

def _task_export(filter_expr: str) -> str:
    r = subprocess.run(["task", "rc.json.array=on", filter_expr, "export"],
                       capture_output=True, text=True, timeout=10)
    return r.stdout if r.returncode == 0 else "[]"

def task_lookup_by_ticket(ticket: str) -> str | None:
    raw = _task_export(f"linearurl.contains:/{ticket}/")
    try:
        tasks = _json.loads(raw or "[]")
    except _json.JSONDecodeError:
        return None
    pending = [t for t in tasks if t.get("status") == "pending"]
    if pending:
        pending.sort(key=lambda t: t.get("entry", ""), reverse=True)
        return pending[0].get("uuid")
    if tasks:
        tasks.sort(key=lambda t: t.get("entry", ""), reverse=True)
        return tasks[0].get("uuid")
    return None

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

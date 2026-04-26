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
from datetime import datetime, timezone
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

class WorktreeCache:
    def __init__(self, path: Path):
        self.path = path
        self._data = self._load()

    def _load(self) -> dict:
        try:
            return _json.loads(self.path.read_text())
        except (OSError, _json.JSONDecodeError):
            return {}

    def _save(self) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        tmp = self.path.with_suffix(".tmp")
        tmp.write_text(_json.dumps(self._data, indent=2))
        tmp.replace(self.path)

    def get(self, wt: str, current_branch: str | None = None) -> dict | None:
        e = self._data.get(wt)
        if not e:
            return None
        if current_branch is not None and e.get("branch") != current_branch:
            return None
        return e

    def put(self, wt: str, *, branch: str, ticket: str | None, uuid: str) -> None:
        self._data[wt] = {
            "branch": branch,
            "ticket": ticket,
            "uuid": uuid,
            "resolved_at": datetime.now(timezone.utc).isoformat(),
        }
        self._save()

    def invalidate(self, wt: str) -> None:
        self._data.pop(wt, None)
        self._save()


def _git_branch(wt: Path) -> str | None:
    try:
        r = subprocess.run(["git", "-C", str(wt), "rev-parse", "--abbrev-ref", "HEAD"],
                           capture_output=True, text=True, timeout=5)
    except (OSError, subprocess.TimeoutExpired):
        return None
    if r.returncode != 0:
        return None
    out = r.stdout.strip()
    if not out or out == "HEAD":
        return None
    return out

def map_worktree_to_task(wt: Path, cfg: Config, cache: WorktreeCache) -> str | None:
    wt_key = str(wt.resolve())
    branch = _git_branch(wt)
    if branch:
        cached = cache.get(wt_key, current_branch=branch)
        if cached:
            return cached["uuid"]
    ticket = parse_ticket(branch or "")
    uuid = None
    if ticket:
        uuid = task_lookup_by_ticket(ticket)
    if uuid:
        if branch:
            cache.put(wt_key, branch=branch, ticket=ticket, uuid=uuid)
        return uuid
    fb = wt / cfg.fallback_uuid_filename
    if fb.exists():
        fb_uuid = fb.read_text().strip()
        if fb_uuid:
            if branch:
                cache.put(wt_key, branch=branch, ticket=ticket, uuid=fb_uuid)
            return fb_uuid
    return None


def main(argv: list[str] | None = None) -> int:
    import sys
    argv = sys.argv[1:] if argv is None else argv
    if argv == ["--version"]:
        print(__version__)
        return 0
    print("timefocus: not yet implemented", file=sys.stderr)
    return 2

def _cgsession_dict() -> dict | None:
    try:
        from Quartz import CGSessionCopyCurrentDictionary  # type: ignore
    except ImportError:
        return None
    return CGSessionCopyCurrentDictionary()

def is_locked() -> bool:
    d = _cgsession_dict()
    if not d:
        return False
    return bool(d.get("CGSSessionScreenIsLocked", False))

_IDLE_RE = re.compile(r'"HIDIdleTime"\s*=\s*(\d+)')

def _parse_ioreg_idle_ns(text: str) -> int:
    m = _IDLE_RE.search(text)
    return int(m.group(1)) if m else 0

def _ioreg_hid_idle_ns() -> int:
    try:
        r = subprocess.run(["ioreg", "-c", "IOHIDSystem"],
                           capture_output=True, text=True, timeout=3)
    except (OSError, subprocess.TimeoutExpired):
        return 0
    return _parse_ioreg_idle_ns(r.stdout)

def idle_seconds() -> int:
    return _ioreg_hid_idle_ns() // 1_000_000_000

TERMINAL_APPS = {"Terminal", "iTerm2", "iTerm", "WezTerm", "Alacritty", "kitty", "Ghostty"}

def _osascript(script: str) -> str | None:
    try:
        r = subprocess.run(["osascript", "-e", script],
                           capture_output=True, text=True, timeout=3)
    except (OSError, subprocess.TimeoutExpired):
        return None
    if r.returncode != 0:
        return None
    return r.stdout.strip() or None

def _frontmost_app() -> str | None:
    return _osascript(
        'tell application "System Events" to get name of (first process whose frontmost is true)'
    )

def _iterm_pwd() -> str | None:
    return _osascript(
        'tell application "iTerm2" to tell current window to tell current session to get variable named "session.path"'
    )

def _terminal_pwd() -> str | None:
    # Terminal.app pwd retrieval is best-effort via tab tty + lsof.
    # Detailed implementation deferred to install-time; daemon falls back gracefully.
    tty = _osascript('tell application "Terminal" to do script "echo $TTY" in selected tab of front window')
    if not tty:
        return None
    try:
        win_id = _osascript('tell application "Terminal" to get id of front window') or ""
        r = subprocess.run(["lsof", "-a", "-d", "cwd", "-p", win_id],
                           capture_output=True, text=True, timeout=3)
        for line in r.stdout.splitlines():
            parts = line.split()
            if parts and parts[-1].startswith("/"):
                return parts[-1]
    except Exception:
        pass
    return None

def terminal_signal(cfg: Config) -> Path | None:
    app = _frontmost_app()
    if not app or app not in TERMINAL_APPS:
        return None
    pwd = _iterm_pwd() if app.startswith("iTerm") else _terminal_pwd()
    if not pwd:
        return None
    p = Path(pwd)
    if not is_worktree(p, cfg):
        return None
    return p.resolve()

EDITOR_APPS_VSCODE = {"Code", "Code - Insiders", "Cursor"}
EDITOR_APPS_JETBRAINS = {"PhpStorm", "IntelliJ IDEA", "PyCharm", "WebStorm", "GoLand", "RubyMine", "DataGrip"}

def _vscode_active_folder() -> str | None:
    p = Path.home() / "Library" / "Application Support" / "Code" / "storage.json"
    try:
        data = _json.loads(p.read_text())
    except (OSError, _json.JSONDecodeError):
        return None
    try:
        folder = data["windowsState"]["lastActiveWindow"]["folder"]
        if folder.startswith("file://"):
            folder = folder[len("file://"):]
        return folder
    except (KeyError, TypeError):
        return None

def _jetbrains_recent_project() -> str | None:
    base = Path.home() / "Library" / "Application Support" / "JetBrains"
    if not base.exists():
        return None
    best, best_m = None, 0.0
    for prod in base.iterdir():
        xml = prod / "options" / "recentProjects.xml"
        if xml.exists():
            try:
                m = xml.stat().st_mtime
                if m > best_m:
                    best_m, best = m, xml
            except OSError:
                pass
    if best is None:
        return None
    try:
        text = best.read_text()
        matches = re.findall(r'<entry\s+key="([^"]+)"', text)
        if not matches:
            return None
        home = str(Path.home())
        path = matches[0].replace("$USER_HOME$", home)
        return path
    except OSError:
        return None

def editor_signal(cfg: Config) -> Path | None:
    app = _frontmost_app()
    if not app:
        return None
    folder = None
    if app in EDITOR_APPS_VSCODE:
        folder = _vscode_active_folder()
    elif app in EDITOR_APPS_JETBRAINS:
        folder = _jetbrains_recent_project()
    if not folder:
        return None
    p = Path(folder)
    if not is_worktree(p, cfg):
        return None
    return p.resolve()

@dataclass
class State:
    current_uuid: str | None = None
    current_since: str | None = None
    pending_target: str | None = None
    pending_since: str | None = None

def load_state(path: Path) -> State:
    try:
        data = _json.loads(path.read_text())
        return State(**{k: data.get(k) for k in State.__dataclass_fields__})
    except FileNotFoundError:
        return State()
    except (_json.JSONDecodeError, TypeError):
        ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        path.replace(path.with_suffix(path.suffix + f".broken-{ts}"))
        return State()

def save_state(path: Path, state: State) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(".tmp")
    tmp.write_text(_json.dumps(state.__dict__, indent=2))
    tmp.replace(path)

def log_decision(path: Path, record: dict) -> None:
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a") as f:
            f.write(_json.dumps(record) + "\n")
    except OSError:
        pass  # disk full or permissions: drop silently per spec

def compute_desired(cfg: Config, state: State, *, locked: bool, idle_s: int,
                    focus_uuid: str | None) -> tuple:
    if locked:
        return ("PAUSED", None)
    if idle_s > cfg.idle_threshold_s:
        return ("PAUSED", None)
    if focus_uuid:
        return ("ACTIVE", focus_uuid)
    if state.current_uuid:
        return ("ACTIVE", state.current_uuid)
    return ("PAUSED", None)

def resolve_focus(cfg: Config) -> Path | None:
    for fn in (claude_signal, terminal_signal, editor_signal):
        try:
            p = fn(cfg)
        except Exception:
            p = None
        if p is not None:
            return p
    return None

if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env bash
# /Users/c/dotfiles/scripts/install_timefocus.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/bin"
AGENTS="$HOME/Library/LaunchAgents"
CFG_DIR="$HOME/.config/timefocus"
CACHE_DIR="$HOME/.cache/timefocus"

mkdir -p "$BIN" "$AGENTS" "$CFG_DIR" "$CACHE_DIR"

# symlink
ln -sfn "$HERE/timefocus.py" "$BIN/timefocus"
chmod +x "$HERE/timefocus.py"

# default config
if [[ ! -f "$CFG_DIR/config.toml" ]]; then
  cat > "$CFG_DIR/config.toml" <<'EOF'
poll_interval_s = 5
idle_threshold_s = 300
switch_debounce_s = 30
min_chunk_s = 30
claude_session_stale_s = 90
worktree_roots = ["/Users/c/work/TOS/code_base_api_bare"]
ticket_regex = '(?i)\b(tos|toss)-(\d+)\b'
linear_url_match = "/{ticket}/"
bugwarrior_pull_throttle_s = 3600
fallback_uuid_filename = ".task-uuid"
log_level = "info"
EOF
  echo "wrote default config: $CFG_DIR/config.toml"
fi

# plists
cp "$HERE/com.c.timefocus.plist"      "$AGENTS/"
cp "$HERE/com.c.timefocus.trim.plist" "$AGENTS/"

# python deps
if ! python3.12 -c "import Quartz" 2>/dev/null; then
  echo "installing pyobjc-framework-Quartz via pipx..."
  pipx install pyobjc-framework-Quartz || \
    python3.12 -m pip install --user pyobjc-framework-Quartz
fi

# load
launchctl unload "$AGENTS/com.c.timefocus.plist"      2>/dev/null || true
launchctl unload "$AGENTS/com.c.timefocus.trim.plist" 2>/dev/null || true
launchctl load   "$AGENTS/com.c.timefocus.plist"
launchctl load   "$AGENTS/com.c.timefocus.trim.plist"

echo "installed. run: timefocus --status"

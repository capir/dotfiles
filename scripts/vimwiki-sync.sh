#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

REPO="$HOME/repos/vimwiki"
ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/vimwiki"
STATE="$HOME/.cache/vimwiki-sync"
LOG="$STATE/vimwiki-sync.log"

mkdir -p "$STATE"
touch "$LOG"

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$LOG"
}

LOCKDIR="$STATE/.lockdir"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
	exit 0
fi

trap 'rmdir "$LOCKDIR"' EXIT

log "Sync start"

# One direction first to resolve conflicts predictably
unison vimwiki

cd "$REPO"
if [ -d .git ] && [ -n "$(git status --porcelain)" ]; then
	git add .
	git commit -m "vimwiki: auto-sync $(date +%F)"
	log "Committed changes"
fi

log "Sync end"

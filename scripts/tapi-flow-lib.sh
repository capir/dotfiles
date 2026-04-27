#!/usr/bin/env bash
# tapi-flow-lib.sh — shared functions for tapi-* helpers.
# Source me: . "$(dirname "$0")/tapi-flow-lib.sh"

set -euo pipefail

TAPI_TRACKERS=(toco ares atlas hermes)
TAPI_REPO_ROOT="/Users/c/work/TOS/code_base_api_bare"
TAPI_BUGWARRIOR_THROTTLE="${HOME}/.cache/bugwarrior/last_pull.ts"
TAPI_BUGWARRIOR_THROTTLE_S=300

log()  { printf '%s\n' "$*" >&2; }
fail() { log "tapi-flow: $*"; exit 1; }

assert_in_tracker() {
  local pwd_real tracker
  pwd_real="$(pwd -P)"
  for tracker in "${TAPI_TRACKERS[@]}"; do
    if [[ "$pwd_real" == "$TAPI_REPO_ROOT/$tracker" ]]; then
      printf '%s' "$tracker"
      return 0
    fi
  done
  fail "must be run from one of {${TAPI_TRACKERS[*]}} worktrees, not $pwd_real"
}

assert_clean_worktree() {
  if ! git diff --quiet --ignore-submodules HEAD --; then
    git status --short >&2
    fail "uncommitted changes present; stash or commit first"
  fi
  if [[ -n "$(git status --porcelain --untracked-files=normal)" ]]; then
    git status --short >&2
    fail "untracked files present; clean or stash first"
  fi
}

assert_on_tracker() {
  local expected current
  expected="$1"
  current="$(git rev-parse --abbrev-ref HEAD)"
  [[ "$current" == "$expected" ]] || \
    fail "HEAD is on '$current', expected tracker '$expected'. Finish the current issue first."
}

assert_on_issue_branch() {
  local current
  current="$(git rev-parse --abbrev-ref HEAD)"
  case "$current" in
    feature/*|hotfix/*) printf '%s' "$current" ;;
    *) fail "HEAD is on '$current'; no active issue on this worktree" ;;
  esac
}

slugify() {
  local s
  s=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
  printf '%s' "${s:0:50}"
}

bugwarrior_pull_throttled() {
  local now last
  now=$(date +%s)
  if [[ -f "$TAPI_BUGWARRIOR_THROTTLE" ]]; then
    last=$(cat "$TAPI_BUGWARRIOR_THROTTLE")
    if (( now - last < TAPI_BUGWARRIOR_THROTTLE_S )); then
      log "bugwarrior-pull skipped (last pull < ${TAPI_BUGWARRIOR_THROTTLE_S}s ago)"
      return 0
    fi
  fi
  log "bugwarrior-pull running..."
  mkdir -p "$(dirname "$TAPI_BUGWARRIOR_THROTTLE")"
  if command -v bugwarrior-pull >/dev/null; then
    timeout 5 bugwarrior-pull >/dev/null 2>&1 || log "bugwarrior-pull failed or timed out"
  else
    log "bugwarrior-pull binary not on PATH; skipping"
  fi
  echo "$now" > "$TAPI_BUGWARRIOR_THROTTLE"
}

task_lookup_by_ticket() {
  local key="$1"
  task rc.json.array=on "linearurl.contains:/$key/" status:pending export 2>/dev/null \
    | python3 -c "
import json, sys
data = json.load(sys.stdin) or []
data.sort(key=lambda t: t.get('entry',''), reverse=True)
print(data[0]['uuid'] if data else '')
"
}

task_tags() {
  local uuid="$1"
  task rc.json.array=on "$uuid" export 2>/dev/null \
    | python3 -c "
import json, sys
data = json.load(sys.stdin) or []
if data:
    for t in data[0].get('tags', []):
        print(t)
"
}

task_description() {
  local uuid="$1"
  task rc.json.array=on "$uuid" export 2>/dev/null \
    | python3 -c "
import json, sys
data = json.load(sys.stdin) or []
print(data[0].get('description','') if data else '')
"
}

task_has_linear_project() {
  local uuid="$1"
  task rc.json.array=on "$uuid" export 2>/dev/null \
    | python3 -c "
import json, sys
data = json.load(sys.stdin) or []
print('yes' if data and data[0].get('linearproject') else 'no')
"
}

classify_ticket() {
  local uuid="$1"
  local has_proj has_bug
  has_proj="$(task_has_linear_project "$uuid")"
  has_bug=no
  while IFS= read -r tag; do
    [[ "$tag" == "Bug" ]] && has_bug=yes
  done < <(task_tags "$uuid")
  if [[ "$has_proj" == yes ]]; then
    printf 'feature'
  elif [[ "$has_bug" == yes ]]; then
    printf 'hotfix'
  else
    printf 'ambiguous'
  fi
}

ticket_from_branch() {
  local branch="$1"
  printf '%s' "$branch" | grep -oiE '\b(tos|toss)-[0-9]+\b' | head -1 | tr '[:lower:]' '[:upper:]'
}

ff_base_branch() {
  local base="$1"
  local bare="$TAPI_REPO_ROOT"
  git -C "$bare" fetch --quiet origin "$base"
  git -C "$bare" update-ref "refs/heads/$base" "refs/remotes/origin/$base"
}

summarize() { log "$*"; }

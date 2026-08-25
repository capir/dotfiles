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
  # Matches, in order of trust: the linearidentifier UDA, the ticket key inside
  # linearurl, the ticket key as a word in the description. Never falls back to
  # "first pending task" — a wrong match silently starts the wrong timer.
  task rc.json.array=on status:pending export 2>/dev/null \
    | TAPI_TICKET_KEY="$key" python3 -c "
import json, os, re, sys
key = os.environ['TAPI_TICKET_KEY'].upper()
word = re.compile(r'(?<![A-Z0-9])' + re.escape(key) + r'(?![0-9])')
data = json.load(sys.stdin) or []
def hit(t):
    if (t.get('linearidentifier') or '').upper() == key:
        return True
    if word.search((t.get('linearurl') or '').upper()):
        return True
    return bool(word.search((t.get('description') or '').upper()))
hits = [t for t in data if hit(t)]
hits.sort(key=lambda t: t.get('entry',''), reverse=True)
print(hits[0]['uuid'] if hits else '')
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

# Every Linear API token in bugwarriorrc, one per line. Linear keys are scoped
# to a single workspace, so a TPI-* ticket is invisible to the TOSV2 token and
# vice versa — the caller has to try them all. `@oracle:eval:<cmd>` entries are
# resolved the way bugwarrior resolves them (run the command, take line one);
# other oracles (@oracle:use_keyring, @oracle:ask_password) are skipped.
linear_tokens() {
  local rc="$HOME/.config/bugwarrior/bugwarriorrc" value
  [[ -f "$rc" ]] || return 0
  while IFS= read -r value; do
    case "$value" in
      '@oracle:eval:'*) bash -c "${value#@oracle:eval:}" 2>/dev/null | head -1 ;;
      '@oracle:'*)      : ;;
      *)                printf '%s\n' "$value" ;;
    esac
  done < <(sed -n 's/^linear\.api_token[[:space:]]*=[[:space:]]*//p' "$rc")
}

linear_token() {
  linear_tokens | head -1
}

# Fetches Linear issue title for ticket key (e.g. TPI-20). Empty on failure.
linear_title() {
  local ticket="$1" token resp title
  while IFS= read -r token; do
    [[ -n "$token" ]] || continue
    resp="$(curl -sS --max-time 5 -X POST https://api.linear.app/graphql \
      -H "Authorization: $token" \
      -H "Content-Type: application/json" \
      -d "{\"query\":\"query{issue(id:\\\"$ticket\\\"){title}}\"}" 2>/dev/null)" || continue
    title="$(linear_title_of "$resp")"
    if [[ -n "$title" ]]; then
      printf '%s' "$title"
      return 0
    fi
  done < <(linear_tokens)
  return 0
}

linear_title_of() {
  printf '%s' "$1" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
issue = ((d or {}).get('data') or {}).get('issue') or {}
print(issue.get('title') or '')
" 2>/dev/null
}

# bugwarrior's linear service has no `linearproject` UDA: it writes the Linear
# project name into Taskwarrior's own `project` field. Read that.
task_has_linear_project() {
  local uuid="$1"
  task rc.json.array=on "$uuid" export 2>/dev/null \
    | python3 -c "
import json, sys
data = json.load(sys.stdin) or []
print('yes' if data and (data[0].get('project') or '').strip() else 'no')
"
}

# The Bug label decides first: a bug inside a project is still a hotfix.
classify_ticket() {
  local uuid="$1"
  local has_proj has_bug
  has_bug=no
  while IFS= read -r tag; do
    [[ "$tag" == "Bug" ]] && has_bug=yes
  done < <(task_tags "$uuid")
  if [[ "$has_bug" == yes ]]; then
    printf 'hotfix'
    return
  fi
  has_proj="$(task_has_linear_project "$uuid")"
  if [[ "$has_proj" == yes ]]; then
    printf 'feature'
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
  # Trust local base branch; user keeps remote sync manual.
  git -C "$bare" rev-parse --verify --quiet "refs/heads/$base" >/dev/null \
    || fail "local branch $base missing in $bare"
}

summarize() { log "$*"; }

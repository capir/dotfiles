#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/bin"
AGENTS="$HOME/Library/LaunchAgents"
TAPI_REPO_ROOT="/Users/c/work/TOS/code_base_api_bare"
TRACKERS=(toco ares atlas hermes)

mkdir -p "$BIN" "$AGENTS"

for h in tapi-feature-start tapi-feature-finish tapi-hotfix-start tapi-hotfix-finish tapi-tracker-resume tapi-status; do
  ln -sfn "$HERE/$h" "$BIN/$h"
done

cp "$HERE/com.c.bugwarrior.pull.plist" "$AGENTS/"
launchctl unload "$AGENTS/com.c.bugwarrior.pull.plist" 2>/dev/null || true
launchctl load   "$AGENTS/com.c.bugwarrior.pull.plist"
mkdir -p "$HOME/.cache/bugwarrior"

for t in "${TRACKERS[@]}"; do
  wt="$TAPI_REPO_ROOT/$t"
  if [[ -d "$wt/.git" ]] || [[ -f "$wt/.git" ]]; then
    hook_dir="$(git -C "$wt" rev-parse --git-path hooks 2>/dev/null)"
    if [[ -d "$hook_dir" ]]; then
      ln -sfn "$HERE/tapi-hooks/pre-commit" "$hook_dir/pre-commit"
      echo "installed pre-commit hook in $wt"
    fi
  fi
done

# Find the worktree currently on develop, if any
develop_wt=""
while IFS= read -r line; do
  case "$line" in
    "worktree "*) wt_path="${line#worktree }" ;;
    "branch refs/heads/develop") develop_wt="$wt_path" ;;
  esac
done < <(git -C "$TAPI_REPO_ROOT" worktree list --porcelain)

if [[ -z "$develop_wt" ]] || [[ ! -d "$develop_wt" ]]; then
  echo "no worktree currently on develop; skip .gitignore append (run manually if needed)"
else
  cd "$develop_wt"
  if ! grep -qF '.task-uuid' .gitignore 2>/dev/null; then
    {
      [[ -f .gitignore ]] && cat .gitignore
      echo ".task-uuid"
    } > .gitignore.new
    mv .gitignore.new .gitignore
    git add .gitignore
    git commit -m "chore(repo): ignore .task-uuid (tapi-flow)"
    git push origin develop || echo "couldn't push .gitignore commit; do manually"
  else
    echo ".gitignore already contains .task-uuid"
  fi
fi

echo "tapi-flow installed."

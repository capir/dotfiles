#!/bin/bash

# upload_commit_rsync_one.sh
# Upload all files changed in a specific git commit to a remote host
# using a single rsync transfer. Remote info is read from .uploadrc in repo root.

set -e

show_help() {
	cat <<EOF
Usage: $0 <commit_hash>

Uploads files changed in a given Git commit to a remote host defined in .uploadrc.

Options:
  -h, --help    Show this help message and exit

Configuration (.uploadrc in repo root):
  REMOTE_HOST          SSH host (can be defined in ~/.ssh/config)
  REMOTE_ROOT          Root path on remote machine where files will be uploaded
  REMOTE_USER_GROUP    user and group for uploaded files. Leave empty to skip chown.
  REMOTE_SUDO_USER     Optional: sudo to this remote user for rsync (requires NOPASSWD). If set, rsync runs via sudo. Combine with REMOTE_USER_GROUP to use --chown during transfer.

Example:
  $0 a1cc40209fcfc03a94a202b50b1a9c1550770ba7
EOF
}

# Handle help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	show_help
	exit 0
fi

if [ "$#" -ne 1 ]; then
	echo "Error: missing commit hash."
	echo
	show_help
	exit 1
fi

COMMIT=$1

# Find Git root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
	echo "Not inside a git repository!"
	exit 1
fi
cd "$REPO_ROOT"

DOTFILE=".uploadrc"

# If dotfile doesn't exist, create a template
if [ ! -f "$DOTFILE" ]; then
	echo "No $DOTFILE found. Creating template..."
	cat >"$DOTFILE" <<'EOF'
# .uploadrc
REMOTE_HOST="yourserver"
REMOTE_ROOT="/var/www/project"
# Optional: user and group for uploaded files. Leave empty to skip chown.
# Example: REMOTE_USER_GROUP="www-data:www-data"
REMOTE_USER_GROUP=""

# Optional: sudo to this user for rsync (requires passwordless sudo).
# Example: REMOTE_SUDO_USER="www-data"  # or leave empty to skip
REMOTE_SUDO_USER=""
EOF
	echo "Template created at $REPO_ROOT/$DOTFILE. Edit it with correct values and rerun the script."
	exit 0
fi

# Load configuration
source "$DOTFILE"
if [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_ROOT" ]; then
	echo "REMOTE_HOST or REMOTE_ROOT not defined in $DOTFILE"
	exit 1
fi

# Get list of files changed in the commit
FILES=$(git diff-tree --no-commit-id --name-only -r "$COMMIT")

if [ -z "$FILES" ]; then
	echo "No files changed in commit $COMMIT"
	exit 0
fi

echo "Files to upload:"
echo "$FILES"
echo
read -p "Proceed with upload to $REMOTE_HOST:$REMOTE_ROOT? [y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
	echo "Aborted."
	exit 0
fi

# Create a temporary file list for rsync
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT
for f in $FILES; do
	# Only include regular files
	if [ -f "$f" ]; then
		echo "$f" >>"$TMPFILE"
	fi
done

# Run rsync once for all files (optionally via sudo on remote)
RSYNC_ARGS=(-v --no-perms --no-owner --no-group --files-from="$TMPFILE")
# Detect local rsync support for --chown (macOS system rsync may be too old)
if rsync --help 2>&1 | grep -q -- '--chown'; then
	CHOWN_SUPPORTED=1
else
	CHOWN_SUPPORTED=0
fi
# If we are sudoing remotely and a user:group is provided, set ownership during transfer when supported
if [ -n "$REMOTE_SUDO_USER" ] && [ -n "$REMOTE_USER_GROUP" ] && [ "$CHOWN_SUPPORTED" -eq 1 ]; then
	RSYNC_ARGS+=(--chown="$REMOTE_USER_GROUP")
elif [ -n "$REMOTE_SUDO_USER" ] && [ -n "$REMOTE_USER_GROUP" ] && [ "$CHOWN_SUPPORTED" -eq 0 ]; then
	echo "Warning: local rsync does not support --chown; will attempt to fix ownership after transfer."
fi
RSYNC_RPATH=()
if [ -n "$REMOTE_SUDO_USER" ]; then
	RSYNC_RPATH=(--rsync-path "sudo -n -u $REMOTE_SUDO_USER rsync")
fi
rsync "${RSYNC_ARGS[@]}" "${RSYNC_RPATH[@]}" ./ "$REMOTE_HOST:$REMOTE_ROOT/"

# Optionally fix ownership on remote for uploaded files
# Run if no remote sudo was used, or if --chown was unavailable locally
if [ -n "$REMOTE_USER_GROUP" ] && { [ -z "$REMOTE_SUDO_USER" ] || [ "${CHOWN_SUPPORTED:-0}" -eq 0 ]; }; then
	echo "Setting ownership to $REMOTE_USER_GROUP on remote files..."
	ssh "$REMOTE_HOST" "cd '$REMOTE_ROOT' && OWNER=\"$REMOTE_USER_GROUP\"; while IFS= read -r p; do if [ -f \"\$p\" ]; then sudo -n chown \"\$OWNER\" -- \"\$p\"; fi; done" <"$TMPFILE" || echo "Warning: Failed to set ownership on remote. Ensure passwordless sudo is available or upgrade rsync to a version supporting --chown."
fi

rm "$TMPFILE"
echo "Upload completed!"

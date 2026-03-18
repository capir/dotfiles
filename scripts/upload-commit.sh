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
  REMOTE_HOST   SSH host (can be defined in ~/.ssh/config)
  REMOTE_ROOT   Root path on remote machine where files will be uploaded

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
for f in $FILES; do
	# Only include regular files
	if [ -f "$f" ]; then
		echo "$f" >>"$TMPFILE"
	fi
done

# Run rsync once for all files
rsync -v --no-perms --no-owner --no-group --files-from="$TMPFILE" ./ "$REMOTE_HOST:$REMOTE_ROOT/"

rm "$TMPFILE"
echo "Upload completed!"

#!/usr/bin/env bash
set -euo pipefail

# Where saved queries live
QUERY_DIR="$HOME/.mongo-queries"
mkdir -p "$QUERY_DIR"

# Pick a database
DB=$(mongosh --quiet --eval 'db.adminCommand("listDatabases").databases.map(d => d.name).join("\n")' |
	fzf --prompt="Database > ")
[ -z "$DB" ] && exit 0

# Pick a collection
COLL=$(mongosh "$DB" --quiet --eval 'db.getCollectionNames().join("\n")' |
	fzf --prompt="Collection > ")
[ -z "$COLL" ] && exit 0

# File for saved queries
QUERY_FILE="$QUERY_DIR/$DB.$COLL.txt"
touch "$QUERY_FILE"

# Default query if no file entries yet
DEFAULT_QUERY="db.$COLL.find().limit(5).pretty()"

# -----------------------------
# FZF Picker: Saved + Default + New/Edit
# -----------------------------
CHOICE=$( (
	cat "$QUERY_FILE"
	echo "$DEFAULT_QUERY"
	echo "<New / Edit in Vim>"
) |
	fzf --prompt="Query > " --select-1 --exit-0)

[ -z "$CHOICE" ] && exit 0

# -----------------------------
# Handle Vim editor if chosen
# -----------------------------
if [[ "$CHOICE" == "<New / Edit in Vim>" ]]; then
	TMPFILE=$(mktemp)
	echo "$DEFAULT_QUERY" >"$TMPFILE"
	"$EDITOR" "$TMPFILE"
	QUERY=$(<"$TMPFILE")
	rm "$TMPFILE"
else
	QUERY="$CHOICE"
fi

[ -z "$QUERY" ] && exit 0

# Make sure .toArray() is used for cursors
if echo "$QUERY" | grep -q "find(" && ! echo "$QUERY" | grep -q "toArray("; then
	EXEC_QUERY="${QUERY}.toArray()"
else
	EXEC_QUERY="$QUERY"
fi

echo "▶ Running on $DB.$COLL:"

# Save output to temp file to enable multiple views / filtering
TMPJSON=$(mktemp)
mongosh "$DB" --quiet --eval "print(EJSON.stringify($EXEC_QUERY))" >"$TMPJSON"

# Step 1: view full JSON
echo "▶ Viewing full JSON (press q to quit)..."
jless "$TMPJSON"

# Step 2: interactive jq filters
while true; do
	echo
	echo "Enter jq filter (or empty to quit):"
	read -r FILTER
	[[ -z "$FILTER" ]] && break

	if ! jq "$FILTER" "$TMPJSON" >/dev/null 2>&1; then
		echo "⚠️ Invalid jq filter. Try again."
		continue
	fi

	echo "▶ Viewing filtered JSON..."
	jq "$FILTER" "$TMPJSON" | jless
done

rm "$TMPJSON"

# Ask to save query
read -rp "Save this query for future use? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
	echo "$QUERY" >>"$QUERY_FILE"
	echo "✅ Saved to $QUERY_FILE"
fi

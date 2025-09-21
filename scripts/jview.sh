#!/usr/bin/env bash
set -euo pipefail

# Read JSON from stdin or file
if [[ -t 0 ]]; then
  # No stdin → require a file argument
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <json-file>"
    exit 1
  fi
  JSON=$(cat "$1")
else
  # Read from pipe
  JSON=$(cat)
fi

# Step 1: View unfiltered JSON
echo "▶ Viewing full JSON..."
echo "$JSON" | jless

# Step 2: Interactive jq filtering
while true; do
  echo
  echo "Enter jq filter to apply (or empty to quit):"
  read -r FILTER
  [[ -z "$FILTER" ]] && break

  # Apply filter and view in jless
  if ! echo "$JSON" | jq "$FILTER" >/dev/null 2>&1; then
    echo "⚠️ Invalid jq filter. Try again."
    continue
  fi

  echo "▶ Viewing filtered JSON..."
  echo "$JSON" | jq "$FILTER" | jless
done

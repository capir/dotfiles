#!/bin/zsh
# Print the URL-encoded password for a DB profile from pass (cli/db/<profile>).
# Used by lazysql connection Commands so special chars don't break the DSN.

pass show "cli/db/$1" | head -n 1 | python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip(), safe=""), end="")'

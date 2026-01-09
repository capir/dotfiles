#!/usr/bin/env bash
# print_motd.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "☀️  $(date '+%A, %d %B')"
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo ""
remind $HOME/dotfiles/remind
hledger is -p "from 4 months ago" --pretty -M -2

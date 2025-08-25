#!/usr/bin/env bash

DATE_BIN="date"

ACTIVE=$(timew get dom.active 2>/dev/null)
OUT=""

if [ -n "$ACTIVE" ]; then
	TAG=$(timew get dom.active.tag.1 2>/dev/null)
	[ -z "$TAG" ] && TAG="(untagged)"

	START=$(timew export | jq -r '.[] | select(.end==null) | .start' 2>/dev/null)

	if [ -n "$START" ] && [ "$START" != "null" ]; then
		START_SEC=$($DATE_BIN -j -u -f "%Y%m%dT%H%M%SZ" "$START" +%s)
		NOW_SEC=$($DATE_BIN +%s)
		DIFF=$((NOW_SEC - START_SEC))
		DUR=$(printf '%02d:%02d:%02d' $((DIFF / 3600)) $((DIFF % 3600 / 60)) $((DIFF % 60)))
		OUT="$TAG ($DUR)"
	fi
fi

# Funcție helper pentru ore
hours_fmt() {
	H=$(timew summary "$1" 2>/dev/null)
	if echo "$H" | grep -q "No filtered data found"; then
		echo "0:00"
	else
		# Extrage ultima coloană și convertește în H:MM
		LAST=$(echo "$H" | awk 'NF {last=$NF} END{print last}')
		awk -F: '{printf "%d:%02d", $1,$2}' <<<"$LAST"
	fi
}

H_TODAY=$(hours_fmt :today)
H_MONTH=$(hours_fmt :month)

H_TODAY=$(hours_fmt :today)
H_MONTH=$(hours_fmt :month)

# Output compact
if [ -n "$OUT" ]; then
	echo "$OUT [$H_TODAY/$H_MONTH]"
else
	echo "off [$H_TODAY/$H_MONTH]"
fi

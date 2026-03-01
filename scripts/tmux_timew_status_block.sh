#!/usr/bin/env bash

OUT=$(~/dotfiles/scripts/tmux_timew_status.sh)

if [[ $OUT == off* ]]; then
	# Task oprit → roșu
	printf " #[noreverse] ⏱ #[fg=#828bb8,bg=#1e2030] %s " "$OUT"
else
	# Task activ → verde
	printf "#[bg=#82aaff,fg=#1e2030]#[reverse]#[noreverse] ⏱ #[fg=#828bb8,bg=#1e2030] %s " "$OUT"
fi

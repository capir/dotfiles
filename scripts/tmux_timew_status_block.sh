#!/usr/bin/env bash

OUT=$(~/dotfiles/scripts/tmux_timew_status.sh)

if [[ $OUT == off* ]]; then
  # Task oprit → roșu
  printf "#[bg=#{@thm_red},fg=#{@thm_crust}]#[reverse]#[noreverse] ⏱ #[fg=#{@thm_fg},bg=#{@thm_mantle}] %s " "$OUT"
else
  # Task activ → verde
  printf "#[bg=#{@thm_green},fg=#{@thm_crust}]#[reverse]#[noreverse] ⏱ #[fg=#{@thm_fg},bg=#{@thm_mantle}] %s " "$OUT"
fi

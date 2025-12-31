# dailymotd.plugin.zsh

autoload -Uz add-zsh-hook
add-zsh-hook precmd _daily_motd

function _daily_motd() {
  add-zsh-hook -d precmd _daily_motd

  CACHE="$HOME/.cache/dailymotd"
  TODAY="$(date +%Y-%m-%d)"

  [[ -d "$CACHE" ]] || mkdir -p "$CACHE"

  # check if today's MOTD has already been shown
  if [[ ! -f "$CACHE/$TODAY" ]]; then
    touch "$CACHE/$TODAY"

    # delegate actual printing
    "$HOME/.oh-my-zsh/custom/plugins/dailymotd/print_motd.sh"
  fi
}

# Optional: helper to manually trigger
function daily_motd() {
  "$HOME/.oh-my-zsh/custom/plugins/dailymotd/print_motd.sh"
}

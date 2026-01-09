# dailymotd.plugin.zsh

[[ -o interactive ]] || return

function _daily_motd() {
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

function p10k-after-init() {
  _daily_motd
}

function p10k-after-init() {
  echo "Powerlevel10k is ready, safe to print now!"
}

# Optional: helper to manually trigger
function daily_motd() {
  "$HOME/.oh-my-zsh/custom/plugins/dailymotd/print_motd.sh"
}

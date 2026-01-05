# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/c/.zsh/completions:"* ]]; then export FPATH="/Users/c/.zsh/completions:$FPATH"; fi
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="wezm"
ZSH_THEME="powerlevel10k/powerlevel10k"

GITSTATUS_LOG_LEVEL=DEBUG
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="${HOME}/dotfiles/omz_custom"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git zsh-completions zsh-autosuggestions)
plugins=(
  brew 
  dailymotd
  docker-compose 
  git 
  docker 
  macos 
  fzf 
  hledger
  httpie
  kitty
  pass 
  vi-mode 
  # timewarrior 
  tmuxinator 
  ssh 
  zsh-autosuggestions
  zsh-syntax-highlighting
  zoxide
)

# User configuration

export PATH="~/.composer/vendor/bin:~/bin:/opt/subversion/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/git/bin"
export PATH=$PATH:~/didit-cli-client
export PATH="$HOME/.npm-packages/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="vendor/bin:$PATH"
# export PATH="$(brew --prefix homebrew/php/php56)/bin:$PATH"
export PATH="bin:$PATH"
export PATH="$PATH:$HOME/go/bin"

export PYTHONPATH=/usr/local/bin/python

# export MANPATH="/usr/local/man:$MANPATH"

# load github.com/zsh-users/zsh-completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

 # export $VISUAL="bat"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
. ~/.aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

source ~/.credentials

DEFAULT_USER="c"

export NVM_DIR=~/.nvm

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
#fpath=(/usr/local/share/zsh-completions $fpath)

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit

export PHPBREW_SET_PROMPT=1
export PHPBREW_RC_ENABLE=1
export PYTHONPATH="/usr/local/lib/python3.9/site-packages:$PYTHONPATH"
export PATH="/opt/homebrew/bin:$PATH"
# source $(brew --prefix nvm)/nvm.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#eval "$(tmuxifier init -)"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
eval "$(fzf --zsh)"
eval "$(cointop completion zsh)"
eval "$(hrvst completion)"
eval "$(ticker completion zsh)"

# finance path for Ledger 
export FINANCE_PATH="${HOME}/Documents/🤑"
export LEDGER_FILE="${HOME}/repos/personal_finance/all.journal"

#eval "$(zoxide init --cmd cd zsh)"

function frg {
    result=$(rg --ignore-case --color=always --line-number --no-heading "$@" |
        fzf --ansi \
        --color 'hl:-1:underline,hl+:-1:underline:reverse' \
        --delimiter ':' \
        --preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
            file=${result%%:*}
            linenumber=$(echo "${result}" | cut -d: -f2)
            if [[ -n "$file" ]]; then
                $EDITOR +"${linenumber}" "$file"
            fi
        }

function hotfix {
    echo "folosesc commit $2"
    git show --pretty="" --name-only $2 > $2.txt
    FILES_COUNT=$(wc -l $2.txt | awk '{print $1}')
    if [ $FILES_COUNT -gt 0 ]
    then
        echo -n "creez arhiva... "
        tar -T $2.txt -czf hotfix.tgz
        echo "[done]"
        rm $2.txt
        echo -n "urc pe server... "
        scp hotfix.tgz $1
        echo "[done]"
        rm hotfix.tgz
    else
        echo 'n-am ce modifica'
    fi
}

function smnd {
    frg $1 ~/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents/c
}

function WkAvg {
   vared -p 'Câte ore?: ' -c hours
   vared -p 'Din data?: ' -c from
   vared -p 'Până la data?: ' -c to
   ((seconds=($(date -j -f '%Y-%m-%d' $to +%s) - $(date -j -f '%Y-%m-%d' $from +%s))))
   blue=$(tput setaf 4)
   normal=$(tput sgr0)

   printf "În ${blue}%.2f${normal} săptămâni am lucrat în medie ${blue}%.2f${normal}h/wk." $(echo "$seconds/(60*60*24*7)"|bc -l) $(echo "$hours/($seconds/(60*60*24*7))" | bc -l)
}

# Created by `pipx` on 2024-06-06 19:53:04
export PATH="$PATH:/Users/c/.local/bin"
export PATH="/opt/homebrew/sbin:$PATH"

lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

function grabWorkspace {
    echo "aduc ch.tar"
    scp tapi:/home/travelapi/prod/ch.tar .
    echo "desfac"
    tar xf ch.tar
    echo "sterg ch.tar"
    rm ch.tar
}
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export PATH="/Users/c/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/Users/c/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
. "/Users/c/.deno/env"

typeset -U fpath    # This ensures each $fpath entry is unique.

timew-pdff() {
  local range="${*:-:lastmonth}"  # default to :lastmonth if no args
  local outfile="timew-$(date +%Y-%m).pdf"

  strip_ansi() {
    sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'
  }

  {
    echo "# Timewarrior Report $range"
    echo

    echo "## Month View"
    echo '```'
    timew month $range rc.color=off | strip_ansi
    echo '```'
    echo

    # raw LaTeX to start new page and restore margins
    echo '\\newpage'
    echo '\\newgeometry{a4paper, landscape, margin=2cm}'
    echo

    echo "## Summary"
    echo '```'
    timew summary $range :annotations rc.color=off | strip_ansi
    echo '```'
  } | pandoc \
        -V geometry:a4paper \
        -V geometry:landscape \
        -V geometry:margin=0.5cm \
        -V monofont="Menlo" \
        -V fontsize=10pt \
        --pdf-engine=xelatex \
        -o "$outfile"

  echo "✅ Report generated: $outfile"
}
timew-pdf() {
  local range="${*:-:lastmonth}"
  local outfile="timew-$(date +%Y-%m).pdf"

  strip_ansi() {
    sed -E 's/\x1B\[[0-9;]*[mK]//g; s/&/\\&/g; s/%/\\%/g; s/_/\\_/g; s/#/\\#/g; s/\$/\\\$/g'
  }

  {
    echo "# Timewarrior Report $range"
    echo

    echo "## Month View"
    echo '```'
    timew month $range rc.color=off | strip_ansi
    echo '```'
    echo

    # Page 2 with wider margins
    echo '\\newpage'
    echo '\\newgeometry{a4paper, landscape, margin=2cm}'
    echo

    echo "## Summary"
    echo '```'
    timew summary $range :annotations rc.color=off | strip_ansi
    echo '```'
  } | pandoc \
        -V geometry:a4paper \
        -V geometry:landscape \
        -V geometry:margin=0.5cm \
        -V monofont="Menlo" \
        -V fontsize=10pt \
        --pdf-engine=xelatex \
        -o "$outfile"

  echo "✅ Report generated: $outfile"
}

a() {
  ANTHROPIC_API_KEY="$(pass show api/token/anthropic)" \
  OPENAI_API_KEY="$(pass show api/token/openai)" \
  aider "$@"
}

# export API_KEYs
# export OPENAI_API_KEY=$(pass show api/token/openai)
# export ANTHROPIC_API_KEY=$(pass show api/token/anthropic)

export GOC_MAIN=~/private
export GOC_PLAIN=~/secure
export GOC_BACKUP="/Volumes/dav/Digi Cloud/private"

# tooluri misto
# remind  - calendarr programabil

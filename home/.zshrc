#!/bin/zsh

# SHELL CONFIG --------------------------------------------------------------- #

export TERM="xterm-256color"
export LS_COLORS="di=1;34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
export SSH_KEY_PATH="$HOME/.ssh/rsa_id"

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Editor
export BAT_PAGER="less -Ris"
export BAT_THEME="Coldark-Dark"
export LESS="-RFi"
export PAGER="less -RFis"
export MANPAGER="sh -c $'col -bx | bat -f --italic-text --tabs 1 -l man'"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="vim"
else
  export EDITOR="vim"
  export LESSEDIT="$EDITOR"
  export GIT_EDITOR="$EDITOR"
fi

bindkey -e # use emacs bindings even with vim as EDITOR


# Exa
# https://the.exa.website/docs/colour-themes
export EXA_ICON_SPACING="2"
export EXA_COLORS="
:sn=1;37:sb=37:
:da=3;37:
:un=31:uu=1;31:
:ur=3;35:uw=3;35:ux=3;35:ue=3;35:
:gr=3;32:gw=3;32:gx=3;32:
:tr=3;31:tw=3;31:tx=3;31:
:su=37:sf=37:xa=0;2;37:
:xx=0;2;37:
"

# SHELL ---------------------------------------------------------------------- #

ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump-${(%):-%m}-${ZSH_VERSION}"
HIST_STAMPS="yyyy-mm-dd"
HYPHEN_INSENSITIVE="true"
DISABLE_UPDATE_PROMPT="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

setopt glob_dots

# cd will never select the parent directory (e.g.: cd ../<TAB>):
zstyle ':completion:*:(cd|mv|cp):*' ignore-parents parent pwd
zstyle ':completion:*:*:vim:*' file-patterns '^*.(aux|log|pdf):source-files' '*:all-files'

# OH-MY-ZSH ------------------------------------------------------------------ #

plugins=(
  # Python
  python
  pip
  pipx
  poetry
  virtualenv

  # Node
  node
  npm

  # Development
  aws
  gcloud
  doctl
  gh
  golang
  heroku
  docker
  docker-compose
  kubectl
  terraform

  # Tools
  asdf
  tmux
  git
  jq
  op

  # Shell
  z
  fd
  fzf
  fzf-tab
  iterm2
  fancy-ctrl-z
  common-aliases
  zsh-syntax-highlighting
)

# PATH CONFIG ---------------------------------------------------------------- #

# Homebrew
if [ -n "/opt/homebrew" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
  export FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"
fi

# Google Cloud
export CLOUDSDK_HOME="$HOME/.google-cloud-sdk"

# FZF
read -r -d '' FZF_DEFAULT_OPTS <<- "EOT"
--height 80%
--layout=reverse
--info=inline
--prompt='  '
--pointer='▶'
--marker='•'
--multi
--preview-window=:hidden
--preview '([[ -f {} && {} == *.json ]] && (cat {} | jq -M | bat --theme ansi -nf -l json)) || ([[ -f {} ]] && (bat --theme=TwoDark -nf -m "config_*:dosini" {} || cat {})) || ([[ -d {} ]] && (exa --tree --icons {} | less)) || echo {} 2> /dev/null | head -200'
--color=fg:7,bg:-1,hl:7:dim,border:5:bold
--color=fg+:5,bg+:-1,hl+:1:bold:underline
--color=prompt:0,pointer:1,marker:1,spinner:3
--color=info:0,header:-1:bold,query:5:bold
--color=preview-fg:-1,preview-bg:-1
--bind '?:toggle-preview'
--bind 'ctrl-a:select-all'
--bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
--bind 'ctrl-e:execute(echo {+} | xargs -o vim)'
--bind 'ctrl-v:execute(code {+})'
--bind 'ctrl-o:execute-silent(open "$(dirname {+})")'
EOT
export FZF_DEFAULT_OPTS

# fzf's command
export FZF_DEFAULT_COMMAND="fd -H -E .git -E node_modules"
# CTRL-T's command
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# ALT-C's command
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"

# export FZF_DEFAULT_COMMAND="fd -HL --type f"



export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------- #

source "$ZSH/oh-my-zsh.sh"
source "$HOME/.iterm2_shell_integration.zsh"
source "$HOME/.aliases"
source "$HOME/.dotfiles/scripts/utils.sh"

PIPX_DEFAULT_PYTHON="$(asdf which python)"

eval "$(starship init zsh)"


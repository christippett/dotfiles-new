#!/bin/zsh

# SHELL CONFIG --------------------------------------------------------------- #

export TERM="xterm-256color"
export SSH_KEY_PATH="$HOME/.ssh/rsa_id"

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="vim"
else
  export EDITOR="mate"
  export LESSEDIT="mate -l %lm %f"
  export GIT_EDITOR="mate -wl1"
  export BAT_PAGER="less -RF"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

bindkey -e # use emacs bindings even with vim as EDITOR

# OH-MY-ZSH ------------------------------------------------------------------ #

ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
HIST_STAMPS="yyyy-mm-dd"
HYPHEN_INSENSITIVE="true"
DISABLE_UPDATE_PROMPT="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

PROJECT_PATHS=(
  ~/Projects
  ~/Projects/personal
  ~/Projects/work
)

plugins=(
  # Python
  python
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
  pj
  fd
  fzf
  iterm2
  fancy-ctrl-z
  common-aliases
  zsh-interactive-cd
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

export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------- #

source "$ZSH/oh-my-zsh.sh"
source "$HOME/.iterm2_shell_integration.zsh"
source "$HOME/.aliases"

eval "$(starship init zsh)"

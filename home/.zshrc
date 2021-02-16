#!/bin/zsh
# shellcheck disable=SC2034

# shellcheck source=./utils.bash
source "$(dirname "$0")/utils.bash"

# ZSH CONFIGURATION ---------------------------------------------------------- #

ZSH_THEME="robbyrussell"
HIST_STAMPS="yyyy-mm-dd"
HYPHEN_INSENSITIVE="true"
DISABLE_UPDATE_PROMPT="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# SHELL CONFIGURATION -------------------------------------------------------- #

export TERM="xterm-256color"
export SSH_KEY_PATH="$HOME/.ssh/rsa_id"

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Editor
bindkey -e # use emacs bindings even with vim as EDITOR

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# EXPORTS -------------------------------------------------------------------- #

# export GOENV_GOPATH_PREFIX="$HOME/.go"
export GOENV_ROOT="$HOME/.goenv"
export CLOUDSDK_HOME="$HOME/.google-cloud-sdk"
export PROJECT_HOME="$HOME/Projects"
export WORKON_HOME="$HOME/.virtualenvs"
export PIPX_HOME="$HOME/.pipx"
export PIPX_BIN_DIR="$PIPX_HOME/bin"
export PIP_REQUIRE_VIRTUALENV=true
export NVM_DIR="$HOME/.nvm"
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

export ZSH="$HOME/.oh-my-zsh"
export PATH="$PIPX_BIN_DIR:/opt/homebrew/bin:$PATH"

# OH-MY-ZSH ------------------------------------------------------------------ #

plugins=(
  common-aliases
  docker
  docker-compose
  fancy-ctrl-z
  fd
  fzf
  gcloud
  gh
  doctl
  aws
  django
  git
  golang
  iterm2
  jq
  kubectl
  node
  npm
  nvm
  poetry
  pyenv
  python
  terraform
  tmux
  virtualenv
  op
  zsh-syntax-highlighting
)

# Homebrew completions
FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

# USER CONFIGURATION --------------------------------------------------------- #

source_if_exists "$ZSH/oh-my-zsh.sh"
source_if_exists "$HOME/z.sh"
source_if_exists "$HOME/.aliases"n
source_if_exists "${HOME}/.iterm2_shell_integration.zsh"

# OTHER ---------------------------------------------------------------------- #

# Go
if (is_installed goenv); then
  eval "$(goenv init -)"
  export PATH="$GOROOT/bin:$PATH:$GOPATH/bin"
fi

# Starship prompt
eval "$(starship init zsh)"

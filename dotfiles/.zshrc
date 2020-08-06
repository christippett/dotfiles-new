#!/bin/bash
# shellcheck disable=SC2034

# FUNCTIONS ------------------------------------------------------------------ #
#
# add resource to path (once and only once)
add_path_to_global_path() {
  local TO_ADD="$1"

  # if in $PATH, remove
  # replace all occurrences - ${parameter//pattern/string}
  [[ ":$PATH:" == *":${TO_ADD}:"* ]] && PATH="${PATH//$TO_ADD:/}"
  # add to PATH
  PATH="${TO_ADD}:$PATH"
  printf "✅  added to global path:\\t%s\\n" "${1/$HOME/~}"
}

# Will source the provided resource if the resource exists
source_if_exists() {
  if [ -f "$1" ]; then
    printf "✅  Sourcing \\t%s\\r" "${1/$HOME/~}"
    # shellcheck disable=SC1090
    . "$1"
  else
    printf "🚨  Unable to source \\t%s\\r" "${1/$HOME/~}"
    sleep 1
  fi
}

# Check if binary installed before running command
quiet_which() {
  which "$1" &>/dev/null
}

# EXPORTS -------------------------------------------------------------------- #

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export TERM="xterm-256color"

# Language
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# SSH
export SSH_KEY_PATH="$HOME/.ssh/rsa_id"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

bindkey -e # use emacs bindings even with vim as EDITOR
# bindkey -v # use vim bindings

# ZSH CONFIGURATION ---------------------------------------------------------- #

ZSH_THEME="robbyrussell"
HIST_STAMPS="yyyy-mm-dd"

# Enable case-insensitive auto-completition
HYPHEN_INSENSITIVE="true"

# Automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Enable command auto-correction.
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Disable marking untracked files in git as dirty (faster status checks)
DISABLE_UNTRACKED_FILES_DIRTY="true"

# ASDF CONFIGURATION + PLUGINS ----------------------------------------------- #

# source asdf completions prior to oh-my-zsh running it's own compinit
# shellcheck disable=SC2206
fpath=($HOME/.asdf/completions $fpath)

# activate asdf before oh-my-zsh so we can use `asdf which` to get gcloud's path
source_if_exists "$HOME/.asdf/asdf.sh"
source_if_exists $HOME/.poetry/env

# shellcheck disable=SC2155
export CLOUDSDK_HOME="$(dirname "$(dirname "$(asdf which gcloud)")")"

export GOPATH="$HOME/.local/go"

# OH-MY-ZSH ------------------------------------------------------------------ #

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  asdf
  docker
  fzf
  # aws
  gcloud
  git
  golang
  node
  npm
  # npx
  python
  pip
  poetry
  zsh-syntax-highlighting
  fancy-ctrl-z
  kubectl
)

# USER CONFIGURATION --------------------------------------------------------- #

### oh-my-zsh
source_if_exists "$ZSH/oh-my-zsh.sh"

### z
source_if_exists "$HOME/z.sh"

### aliases
source_if_exists "$HOME/.aliases"

### custom zsh profile
source_if_exists "$HOME/.zprofile"

### Go
# Add Go bin to PATH

quiet_which go && PATH="$(go env GOPATH)/bin:$PATH"

### Python
# Add packages installed with pipx to PATH
if (quiet_which pipx); then
  PATH="$HOME/.local/bin:$PATH"
  VIRTUALENVWRAPPER_PYTHON="$HOME/.local/pipx/venvs/virtualenvwrapper/bin/python"
  unalias ipython >/dev/null 2>&1 # remove oh-my-zsh's alias for ipython
fi

# virtualenvwrapper
PIP_REQUIRE_VIRTUALENV=true
PROJECT_HOME="$HOME/projects"
WORKON_HOME="$HOME/.virtualenvs"
source_if_exists "$HOME/.local/bin/virtualenvwrapper.sh"

### Terraform
TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

### https://starship.rs
eval "$(starship init zsh)"

### Shell setup complete
printf "\\r🕒  %s (%s)                      \\n" "$(date +"%A %d %B, %Y")" "$(date +"%r")"

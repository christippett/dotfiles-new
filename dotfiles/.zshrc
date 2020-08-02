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

# ZSH CONFIGURATION ---------------------------------------------------------- #

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# ASDF CONFIGURATION + PLUGINS ----------------------------------------------- #

# source asdf completions prior to oh-my-zsh running it's own compinit
# shellcheck disable=SC2206
fpath=($HOME/.asdf/completions $fpath)

# activate asdf before oh-my-zsh so we can use `asdf which` to get gcloud's path
source_if_exists "$HOME/.asdf/asdf.sh"

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

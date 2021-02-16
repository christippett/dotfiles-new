#!/usr/bin/env bash

DOTFILES_ROOT="$HOME/.dotfiles"

# Environment ---------------------------------------------------------------- #

OS="$(uname -s)"
[ "$OS" = "Darwin" ] && export MACOS=1 && export UNIX=1
[ "$OS" = "Linux" ] && export LINUX=1 && export UNIX=1

uname -s | grep -q "_NT-" && export WINDOWS=1
grep -q -i "microsoft" /proc/version 2>/dev/null && export WSL=1

# Logging functions ---------------------------------------------------------- #

function log_failure_and_exit() {
  printf "💀  %s\\n" "${@}"
  exit 1
}

function log_failure() {
  printf "🚨  %s\\n" "${@}"
}

function log_info() {
  printf "ℹ️  %s\\n" "${@}"
}

function log_success() {
  printf "✅  %s\\n" "${@}"
}

function log_warning() {
  printf "⚠️  %s\\n" "${@}"
}

# Utility functions ---------------------------------------------------------- #

# Identify if running in WSL
# https://stackoverflow.com/a/38859331
function is_wsl() {
	grep -E -q -m 1 microsoft /proc/version 2>/dev/null || false
}

# Check if command is available
function is_installed() {
  command -v "$1" >/dev/null 2>&1
}

# Will source the provided resource if the resource exists
function source_if_exists() {
  if [ -f "$1" ]; then
    . "$1"
  else
    printf "⚠️ Unable to source %s\\n" "${1/$HOME/~}"
  fi
}

# Add resource to path (once and only once)
function add_to_path() {
  local TO_ADD="$1"

  # Remove item if already in $PATH - ${parameter//pattern/string}
  [[ ":$PATH:" == *":${TO_ADD}:"* ]] && PATH="${PATH//$TO_ADD:/}"
  PATH="${TO_ADD}:$PATH"

  printf "⚙️ Appending \$PATH: %s\\n" "${1/$HOME/~}"
}

function link_dotfiles() {
  # get absolute path of dotfiles directory
  dotfiles_path="$DOTFILES_ROOT/home"

  if [[ -n "$MACOS" ]]; then
    dotfiles_path="$(greadlink -f "$dotfiles_path")" # requires coreutils
  else
    dotfiles_path="$(readlink -f "$dotfiles_path")"
  fi

  # loop through and create symlinks for all dotfiles
  while IFS= read -r -d '' file; do
    file_absolute_path="$file"
    file_relative_path="${file_absolute_path#$DOTFILES_ROOT/}"
    home_path="$HOME/$file_relative_path"

    if [[ ! -d $file ]]; then
      if [[ -L $home_path ]]; then
        # remove existing symlink
        rm -f "$home_path"
      elif [[ -f $home_path ]]; then
        # rename existing file if present
        backup_file "$home_path"
      else
        # ensure nested path exists
        mkdir -p "$HOME/$(dirname "$file_relative_path")"
      fi
      log_info "ℹ️  Creating symlink: ~/$file_relative_path"
      ln -sv "$file_absolute_path" "$home_path"
    fi
  done < <(find "$dotfiles_path" -path '**/*' -type f -print0)
}

# Backup file if exists
function backup_file() {
  local file="$1"
  if [[ -L $file ]]; then
    # File is symlink, safely remove
    rm -fv "$file"
  elif [[ -f $file ]]; then
    # Backup & remove existing file
    backup_file="$file.$(date +'%Y%m%d').bak"
    mv -fv "$file" "$backup_file" && rm -fv "$file"
  fi
}

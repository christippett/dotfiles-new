#!/usr/bin/env bash

DOTFILES_ROOT="$HOME/.dotfiles"

# Environment ---------------------------------------------------------------- #

OS="$(uname -s)"
[ "$OS" = "Darwin" ] && export MACOS=1 && export UNIX=1
[ "$OS" = "Linux" ] && export LINUX=1 && export UNIX=1

uname -s | grep -q "_NT-" && export WINDOWS=1
grep -q -i "microsoft" /proc/version 2>/dev/null && export WSL=1

# Logging functions ---------------------------------------------------------- #

function _fmt() {
  local msg="$1"
  for style in "${@:2}"; do
    case "${style}" in
    black)
      msg="$(printf $'\033[30m%s\033[0m' "$msg")"
      ;;
    red)
      msg="$(printf $'\033[31m%s\033[0m' "$msg")"
      ;;
    green)
      msg="$(printf $'\033[32m%s\033[0m' "$msg")"
      ;;
    yellow)
      msg="$(printf $'\033[33m%s\033[0m' "$msg")"
      ;;
    blue)
      msg="$(printf $'\033[34m%s\033[0m' "$msg")"
      ;;
    purple)
      msg="$(printf $'\033[35m%s\033[0m' "$msg")"
      ;;
    cyan)
      msg="$(printf $'\033[36m%s\033[0m' "$msg")"
      ;;
    white)
      msg="$(printf $'\033[37m%s\033[0m' "$msg")"
      ;;
    bold)
      msg="$(printf $'\033[1m%s\033[0m' "$msg")"
      ;;
    italic)
      msg="$(printf $'\033[3m%s\033[0m' "$msg")"
      ;;
    underline)
      msg="$(printf $'\033[4m%s\033[0m' "$msg")"
      ;;
    esac
  done
  printf $'%s\033[0m' "$msg"
}

function log() {
  local msg="$1"
  local icon="$2"
  local icon_style="$3"
  local styles=("${@:4}")

  # format + print icon if provided
  if [[ -n ${2+x} ]]; then
    _fmt "$icon  " "$icon_style"
  fi

  # set default style if none provided (excluding icon style)
  # if [[ "${#@}" -le 3 ]]; then
  #   styles=(white)
  # fi

  printf '%s\n' "$(_fmt "$msg" "${styles[@]}")"
}

function log_failure_and_exit() {
  log "$1" ' ' red
  exit 1
}

function log_failure() {
  log "$1" ' ' red
}

function log_info() {
  log "$1" ' ' blue
}

function log_success() {
  log "$1" ' ' green
}

function log_warning() {
  log "$1" ' ' yellow
}

function log_header() {
  local style
  printf '\n'
  if [ -n "$1" ]; then
    log "$@" "$3" bold italic
  fi
  _fmt $'\n\n'
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
    log_warning "Unable to source ${1/$HOME/'~'}"
  fi
}

# Add resource to path (once and only once)
function add_to_path() {
  local TO_ADD="$1"

  # Remove item if already in $PATH - ${parameter//pattern/string}
  [[ ":$PATH:" == *":${TO_ADD}:"* ]] && PATH="${PATH//$TO_ADD:/}"
  PATH="${TO_ADD}:$PATH"

  log_info "Appending to path: ${1/$HOME/~}"
}

function link_dotfiles() {
  log $'Symlinking dotfiles...'  white italic
  # get absolute path of dotfiles directory
  dotfiles_home="$DOTFILES_ROOT/home"

  if [[ -n "$MACOS" ]]; then
    dotfiles_home="$(greadlink -f "$dotfiles_home")" # requires coreutils
  else
    dotfiles_home="$(readlink -f "$dotfiles_home")"
  fi

  # loop through and create symlinks for all dotfiles
  while IFS= read -r -d '' file; do
    file_absolute_path="$file"
    file_relative_path="${file_absolute_path#$dotfiles_home/}"
    dotfile="$HOME/$file_relative_path"

    if [[ ! -d $file ]]; then
      if [[ -L $dotfile ]]; then
        # remove existing symlink
        rm -f "$dotfile"
      elif [[ -f $dotfile ]]; then
        # rename existing file if present
        backup_file "$dotfile"
      else
        # ensure nested path exists
        mkdir -p "$HOME/$(dirname "$file_relative_path")"
      fi
      log_info "Creating symlink: ~/$file_relative_path"
      ln -s "$file_absolute_path" "$dotfile"
    fi
  done < <(find "$dotfiles_home" -path '**/*' -type f -print0)
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

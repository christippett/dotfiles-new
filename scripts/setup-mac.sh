#!/usr/bin/env bash

set -e

# shellcheck source=./utils.sh
source "$(dirname "$0")/utils.sh"

if [ -z "$MACOS" ]; then
  log_failure_and_exit "This script is designed to run on Mac OS only"
fi

# Install XCode command-line tools ------------------------------------------- #

log_info "Installing XCode command-line tools"
xcode-select --install 2>&1 | grep installed;

# Install Homebrew + packages ------------------------------------------------ #

log_info "Installing Homebrew packages..."

! is_installed brew && sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew bundle --quiet --file ../dotfiles/.Brewfile

log_success "Homebrew installation complete"

# Install other dependencies ------------------------------------------------- #

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

# Done ----------------------------------------------------------------------- #

set +e
log_info "🏁  Mac OS setup complete!" && exit 0


#!/usr/bin/env bash

# set -eo pipefail

set -ex

# shellcheck source=./utils.sh
source "$(dirname "$0")/utils.sh"

if [ -z "$LINUX" ]; then
  log_failure_and_exit "This script is designed to run on Ubuntu only"
fi

# Install packages ----------------------------------------------------------- #

log_info "Installing packages from apt..."

apt_packages=(
  autoconf
  automake
  batcat
  build-essential
  curl
  dirmngr
  fontconfig
  fzf
  git
  gpg
  libbz2-dev
  libffi-dev
  liblzma-dev
  libncurses5-dev
  libreadline-dev
  libsqlite3-dev
  libssl-dev
  libtool
  libxml2-dev
  libxmlsec1-dev
  llvm
  make
  ripgrep
  tk-dev
  wget
  xz-utils
  zlib1g-dev
  zsh
)
sudo apt update -y
sudo apt install -y --no-install-recommends "${apt_packages[@]}"

log_success "Package installation complete"

# Install other dependencies ------------------------------------------------- #

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

# Done ----------------------------------------------------------------------- #

set +e
log_info "🏁  Ubuntu setup complete!" && exit 0


#!/usr/bin/env bash

set -e

# shellcheck source=./utils.sh
source "$(dirname "$0")/utils.sh"

# shellcheck source=./userdata.sh
source "$(dirname "$0")/userdata.sh"

# Install oh-my-zsh ---------------------------------------------------------- #

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log_info "Installing Oh-My-Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# Install Nerd fonts --------------------------------------------------------- #

if fc-list : file family | grep -iq 'nerd'; then
  log_info "Installing Nerd fonts"
  git clone https://github.com/ryanoasis/nerd-fonts.git --depth=1 "/tmp/fonts"
  /tmp/fonts/install.sh
  rm -rf /tmp/fonts
fi

# Install Starship prompt ---------------------------------------------------- #

if ! is_installed starship; then
  log_info "Installing Starship prompt 🚀"
  curl -fsSL https://starship.rs/install.sh | bash
fi

# Install asdf --------------------------------------------------------------- #

ASDF_DATA_DIR="$HOME/.asdf"

if ! is_installed asdf; then
  log_info "Installing asdf-vm"
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DATA_DIR" --branch v0.8.0

  # import the Node.js release team's OpenPGP keys to main keyring
  eval "$("$ASDF_DATA_DIR"/plugins/nodejs/bin/import-release-team-keyring)"
fi

# Install Vundle Plugin Manager ---------------------------------------------- #

if [ ! -f "$HOME/.vim/bundle/Vundle.vim" ]; then
  log_info "Installing Vundle plugin manager"
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Misc ----------------------------------------------------------------------- #

link_dotfiles  # recursively symlink files from ./home to $HOME
sync_1password # sync files 1password

# Update shell --------------------------------------------------------------- #

if [[ "$SHELL" != *"zsh"* ]]; then
  log_info "Setting default shell to ZSH"
  chsh -s "$(command -v zsh)" "$(whoami)"
fi

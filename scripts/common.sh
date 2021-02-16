#!/usr/bin/env bash

set -e

# shellcheck source=./utils.sh
source "$(dirname "$0")/utils.sh"


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

# Update shell --------------------------------------------------------------- #

if [[ "$SHELL" != *"zsh"* ]]; then
  log_info "Setting default shell to ZSH"
  chsh -s "$(command -v zsh)" "$(whoami)"
fi

# Install asdf --------------------------------------------------------------- #

if ! is_installed asdf; then
  log_info "Installing asdf-vm"
  git clone https://github.com/asdf-vm/asdf.git "${HOME}/.asdf" --branch v0.8.0
fi

# Symlink dotfiles ----------------------------------------------------------- #

link_dotfiles ""

#!/usr/bin/env bash

set -e

# shellcheck source=./utils.sh
source "$(dirname "$0")/utils.sh"

# shellcheck source=./userdata.sh
source "$(dirname "$0")/userdata.sh"

# Install oh-my-zsh ---------------------------------------------------------- #

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log_header "Installing Oh-My-Zsh"  yellow
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# Install Nerd fonts --------------------------------------------------------- #

if ! fc-list : file family | rg -q 'Nerd'; then
  log_header "Installing Nerd fonts"  blue
  git clone https://github.com/ryanoasis/nerd-fonts.git --depth=1 "/tmp/fonts"
  /tmp/fonts/install.sh
  rm -rf /tmp/fonts
fi

# Install Starship prompt ---------------------------------------------------- #

if ! is_installed starship; then
  log_header "Installing Starship prompt"  red
  curl -fsSL https://starship.rs/install.sh | bash
fi

# Install asdf --------------------------------------------------------------- #

ASDF_DATA_DIR="$HOME/.asdf"

if ! is_installed asdf; then
  log_header "Installing asdf-vm"  purple
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DATA_DIR" --branch v0.8.0

  # import the Node.js release team's OpenPGP keys to main keyring
  eval "$("$ASDF_DATA_DIR"/plugins/nodejs/bin/import-release-team-keyring)"
fi

# Install Vundle Plugin Manager ---------------------------------------------- #

if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  log_header "Installing Vundle"  green
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Update shell --------------------------------------------------------------- #

if [[ "$SHELL" != *"zsh"* ]]; then
  log_header "Configuring ZSH"  white
  chsh -s "$(command -v zsh)" "$(whoami)"
fi

# Misc ----------------------------------------------------------------------- #
log_header "Misc"  white

link_dotfiles # recursively symlink files from ./home to $HOME
printf "\n"
sync_1password # sync files 1password

#!/usr/bin/env bash

set -eo pipefail

# shellcheck source=./utils.bash
source "$(dirname "$0")/utils.bash"

# Dependencies
log_info "Installing dependencies"
if [ "$(whoami)" == "root" ]; then
(
		apt update
		apt install git curl fontconfig
		apt install \
			automake autoconf libreadline-dev \
			libncurses-dev libssl-dev libyaml-dev \
			libxslt-dev libffi-dev libtool unixodbc-dev \
			unzip
		log_success "Successfully installed dependencies"
	) || log_failure "Unable to install dependencies"
fi

############ BEGIN: ZSH
if [[ ! "$(which zsh)" ]]; then
	log_info "Installing ZSH"
	sudo apt update && apt install zsh -y
else
	log_success "ZSH already installed"
fi

# install oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
	log_success "oh-my-zsh already installed"
else
	log_info "Installing oh-my-zsh"
	RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

	log_info "Installing zsh-syntax-highlighting plugin"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

# add fonts for powerline
if [ -n "$(fc-list : file family | grep -iqs powerline || true)" ]; then
	log_success "Powerline fonts already installed"
else
	log_info "Installing powerline fonts"
	git clone https://github.com/powerline/fonts.git --depth=1 "/tmp/fonts"
	/tmp/fonts/install.sh
	rm -rf /tmp/fonts
fi

# change default shell
if [[ "$SHELL" == *"zsh"* ]]; then
	log_success "ZSH already set as default shell"
else
	log_info "Setting default shell to ZSH"
	chsh -s "$(command -v zsh)"
fi

############ END: ZSH

# install fzf
if [ -d "${HOME}/.fzf" ]; then
	log_success "fzf already installed"
else
	log_info "Installing fzf"
	git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
	~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-zsh
fi

# dynamically symlink all config/dotfiles to home directory
# shellcheck source=./symlink-dotfiles.bash
source "$(dirname "$0")/symlink-dotfiles.bash"

log_info "🏁  Fin"

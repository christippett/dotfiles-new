#!/bin/bash

set -euo pipefail

# shellcheck source=./utils.bash
source "$(dirname "$0")/utils.bash"

# get OS name
osType="$(uname -s)"


case "${osType}" in
Linux*)
    log_info "ℹ️  Installing Ubuntu extras"
    # install improved cli tools
    sudo apt-get install htop ncdu
    # install bat (package only available in apt repository since 19.10)
    wget -O /tmp/bat.deb https://github.com/sharkdp/bat/releases/download/v0.13.0/bat_0.13.0_amd64.deb
    sudo dpkg -i /tmp/bat.deb && rm -f /tmp/bat.deb
    # install prettyping - http://denilson.sa.nom.br/prettyping/
    curl -O https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
    chmod +x prettyping
    sudo mv prettyping /usr/local/bin
    ;;
Darwin*)
    log_info "ℹ️  Installing MacOS extras"
    ;;
*)
    log_failure_and_exit "Script only supports macOS and Ubuntu"
    ;;
esac

# Python
pipx install black
pipx install awscli
pipx install youtube-dl
pipx install poetry
pip install virtualenvwrapper && pip inject virtualenvwrapper virtualenv && mkdir $HOME/.virtualenvs
mkdir -p $ZSH/custom/plugins/poetry && poetry completions zsh > $ZSH/custom/plugins/poetry/_poetry
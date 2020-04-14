#!/bin/bash

set -eo pipefail

# shellcheck source=./utils.bash
source "$(dirname "$0")/utils.bash"

### OS utilities
if [ -n "$LINUX" ]; then
    log_info "Installing Linux utilities"

    is_installed htop || sudo apt install -y htop # install htop: interactive text-mode process viewer
    is_installed ncdu || sudo apt install -y ncdu # install ncdu: disk usage analyzer
    is_installed jq || sudo apt install -y jq # install jq: command-line json processor

    # install bat: a cat clone with wings (https://github.com/sharkdp/bat)
    # note: package available in apt repository from 19.10
    if ! is_installed bat; then
        wget -q -O /tmp/bat.deb https://github.com/sharkdp/bat/releases/download/v0.13.0/bat_0.13.0_amd64.deb
        sudo dpkg -i /tmp/bat.deb && rm -f /tmp/bat.deb
    fi

    # install prettyping: wrapper around ping (http://denilson.sa.nom.br/prettyping/)
    if ! is_installed prettyping; then
        wget -q https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
        chmod +x prettyping
        sudo mv -f prettyping /usr/local/bin
    fi

    # install 1password (https://support.1password.com/command-line-getting-started)
    if ! is_installed op; then
        wget -q -O /tmp/1password.zip https://cache.agilebits.com/dist/1P/op/pkg/v0.9.4/op_linux_amd64_v0.9.4.zip
        unzip -q -o /tmp/1password.zip -d /tmp/1password/
        sudo mv -f /tmp/1password/op /usr/local/bin
        rm -rfv /tmp/1password*
    fi

    # install doctl: digital ocean cli
    if ! is_installed doctl; then
        wget -q -O /tmp/doctl.tar.gz https://github.com/digitalocean/doctl/releases/download/v1.39.0/doctl-1.39.0-linux-amd64.tar.gz
        mkdir /tmp/doctl && tar xf /tmp/doctl.tar.gz -C /tmp/doctl
        sudo mv -f /tmp/doctl/doctl /usr/local/bin
        rm -rfv /tmp/doctl*
    fi
fi

if [ -n "$MACOS" ]; then
    # note: in most cases macos packages/applications should be specified and installed from Brewfile
    log_info "Installing MacOS utilities"
    is_installed op || brew cask install 1password # install op: 1password
fi

if [ -n "$WSL" ]; then
    log_info "Installing Windows utilities"
    username="$(cmd.exe /c "echo %USERNAME%" 2>/dev/null)" # get windows user name
fi


### Python utilities
if is_installed pipx; then
    log_info "Installing Python utilities"

    is_installed black || pipx install black # install black: opinioned python formatter
    is_installed aws || pipx install awscli # install awscli: amazon web services cli
    is_installed youtube-dl || pipx install youtube-dl # install youtube-dl: cli video download tool

    # install poetry: python package manager
    if ! is_installed poetry; then
        pipx install poetry
        mkdir -p $ZSH/custom/plugins/poetry && poetry completions zsh > $ZSH/custom/plugins/poetry/_poetry
    fi

    # install virtualenvwrapper: wrapper around python's virtualenv
    if [ ! -f "$HOME/.local/bin/virtualenvwrapper.sh" ]; then
        pipx install virtualenvwrapper
        pipx inject virtualenvwrapper virtualenv # required to resolve module import dependency
        mkdir -p $HOME/.virtualenvs # should be set to the same value as $WORKON_HOME in ~/.zshrc
    fi
else
    log_failure "Missing pipx installation, skipping install of Python utilities"
fi


### 1Password secrets
log_info "Getting secrets and configuration files from 1Password"

function get_document_label() {
    local label="$1"
    local doc="$(</dev/stdin)"
    jq -cr --arg v "$label" '.details.sections[].fields[]? | select(.t == $v) | .v' <<<  "$doc"
}

function get_document() {
    local item="$(op get item "$uuid")"
    local path="$(get_document_label "path" <<< "$item" | sed -e 's#~#'"$HOME"'#')"
    local chmod="$(get_document_label "chmod" <<< "$item")"
    mkdir -p "$(dirname "$path")"
    backup_file "$path"
    op get document "$uuid" > "$path"
    chmod ${chmod:-644} "$path"
    log_success "Saved file to $path (chmod: ${chmod:-644})"
}

# configure / sign into 1password
if [ -n "$OP_SESSION_my" ]; then
    read -p "Enter your 1Password email address: " email_address
    eval $(op signin my "$email_address")
fi

# loop through each 1password document and save to the relevant path
op list documents | jq -c -r '.[] | [.uuid, .overview.title] | @tsv' |
while IFS=$'\t' read -r uuid title; do
    log_info "Getting document from 1Password: $title"
    get_document $uuid </dev/null
done

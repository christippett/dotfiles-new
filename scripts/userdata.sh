#!/bin/bash

set -eo pipefail

# shellcheck source=./utils.bash
source "$(dirname "$0")/utils.bash"

### Install 1Password CLI (https://support.1password.com/command-line-getting-started)
if [ -n "$LINUX" ]; then
  if ! is_installed op; then
    wget -q -O /tmp/1password.zip https://cache.agilebits.com/dist/1P/op/pkg/v0.9.4/op_linux_amd64_v0.9.4.zip
    unzip -q -o /tmp/1password.zip -d /tmp/1password/
    sudo mv -f /tmp/1password/op /usr/local/bin
    rm -rfv /tmp/1password*
  fi
fi

if [ -n "$MACOS" ]; then
  is_installed op || brew cask install 1password-cli # install op: 1password
fi

### 1Password secrets
log_info "Getting user-data from 1Password"

function get_document_label() {
  local label="$1"
  local doc="$(</dev/stdin)"
  jq -cr --arg v "$label" '.details.sections[].fields[]? | select(.t == $v) | .v' <<<"$doc"
}

function get_document() {
  local item="$(op get item "$uuid")"
  local path="$(get_document_label "path" <<<"$item" | sed -e 's#~#'"$HOME"'#')" # get value specified in document's `path` label
  local chmod="$(get_document_label "chmod" <<<"$item")"                         # get value specified in document's `chmod` label
  mkdir -p "$(dirname "$path")"
  backup_file "$path"
  op get document "$uuid" >"$path" # download and save contents of document
  chmod "${chmod:-644}" "$path"
  log_success "Saved file to $path (chmod: ${chmod:-644})"
}

# configure / sign into 1password
if [ -z "$OP_SESSION_my" ]; then
  read -p "Enter your 1Password email address: " email_address
  eval $(op signin my "$email_address")
fi

# loop through each 1password document and save it to the location specified by the document's `path` label
op list documents --vault "Dotfiles" | jq -c -r '.[] | [.uuid, .overview.title] | @tsv' |
  while IFS=$'\t' read -r uuid title; do
    log_info "Getting document from 1Password: $title"
    get_document "$uuid" </dev/null
  done

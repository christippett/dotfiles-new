#!/bin/bash

set -e

export DOTFILES_VAULT="Dotfiles"

# shellcheck source=./utils.sh
source "$(dirname "$0")/utils.sh"

### 1Password secrets
log_info "Getting user-data from 1Password"

function get_document_label() {
  local uuid label
  uuid="$1"
  label="$2"
  op get item "$uuid" |
    jq -cr --arg v "$label" '.details.sections[].fields[]? | select(.t == $v) | .v'
}

function get_chmod() {
  local fp="$1"
  if [ "$MACOS" == 1 ]; then
    stat -f "%OLp" "$fp"
  elif [ "$LINUX" == 1 ]; then
    stat -f "%a" "$fp"
  fi
}

function get_document() {
  local title="$1"
  op list items --vault "$DOTFILES_VAULT" | jq -rc --arg fp "$title" '.[] | select(.overview.title==$fp)'
}

function download_document() {
  local uuid="$1"
  local path="${2//'~'/$HOME}"

  mkdir -p "$(dirname "$path")"
  backup_file "$path"
  op get document "$uuid" >"$path" # download and save document

  # chmod "$(get_document_label "$uuid" 'chmod' || '0644')" "$path"

  log_success "Downloaded ${path} from ${uuid}"
}

function upload_document() {
  local uuid="$1"
  local title="$2"
  local path="${2//'~'/$HOME}"

  op edit document "$uuid" "$path" \
    --vault "$DOTFILES_VAULT" ||
    op create document "$path" \
      --filename "$(basename "$path")" \
      --title "$title" \
      --vault "$DOTFILES_VAULT" -- # upload document

  # chmod="$(get_chmod "$path" || '0644')" # get file's numerical chmod value
  # op edit item "$uuid" "chmod=${chmod}" --vault "$DOTFILES_VAULT"

  log_success "Uploaded ${path} to ${uuid}"
}

function sync_1password() {
  # configure / sign into 1password
  if [ -z "$OP_SESSION_my" ]; then
    read -rp "Enter your 1Password email address: " email_address
    eval "$(op signin my "$email_address")"
  fi

  # loop through each 1password document and save it to the location specified by the document's `path` label
  op list documents --vault "$DOTFILES_VAULT" | jq -c -r '.[] | [.uuid, .overview.title] | @tsv' |
    while IFS=$'\t' read -r uuid title; do
      if [[ "$title" != '~'/* ]]; then
        continue
      fi
      file_dt="$(gdate -ur "${title//'~'/$HOME}" '+%s' || echo 0)"
      doc_dt="$(get_document "$title" | jq -rc '.updatedAt' | xargs gdate -u '+%s' -d)"
      if [ "$doc_dt" -ge "$file_dt" ]; then
        download_document "$uuid" "$title" </dev/null
      else
        upload_document "$uuid" "$title" </dev/null
      fi
    done
}

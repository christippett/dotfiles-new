#!/bin/bash

#set -e
#set -x

export DOTFILES_VAULT="Dotfiles"
export fp="$HOME/.asdf/shims/:$fp"

# shellcheck source=./utils.sh
source "$(dirname "$0")/utils.sh"

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
  local title="$2"
  local fp="${2//\~/$HOME}"

  mkdir -p "$(dirname "$fp")"
  backup_file "$fp" >/dev/null 2>&1
  op get document "$uuid" >"$fp" # download and save document

  # chmod "$(get_document_label "$uuid" 'chmod' || '0644')" "$fp"

  log "${title}"  green
}

function upload_document() {
  local uuid="$1"
  local title="$2"
  local fp="${2//\~/$HOME}"
  
  op edit document "$uuid" "$fp" \
    --vault "$DOTFILES_VAULT" ||
    op create document "$fp" \
      --filename "$(basename "$fp")" \
      --title "$title" \
      --vault "$DOTFILES_VAULT" -- # upload document

  # chmod="$(get_chmod "$fp" || '0644')" # get file's numerical chmod value
  # op edit item "$uuid" "chmod=${chmod}" --vault "$DOTFILES_VAULT"

  log "${title}"  red
}

function sync_1password() {
  log $'Syncing files with 1Password...'  white italic

  # configure / sign into 1password
  if [ -z "$OP_SESSION_my" ]; then
    read -rp "Enter your 1Password email address: " email_address

    eval "$(op signin my "$email_address")"
  else
    eval "$(op signin my --session "$OP_SESSION_my")"
  fi

  # loop through each 1password document and save it to the location specified by the document's `fp` label
  op list documents --vault "$DOTFILES_VAULT" | jq -c -r '.[] | [.uuid, .overview.title] | @tsv' |
    while IFS=$'\t' read -r uuid title; do
      if [[ "$title" != '~'/* ]]; then
        continue
      fi
      file_dt="$(date -ur "${title//'~'/$HOME}" '+%s' || echo 0)"
      doc_dt="$(get_document "$title" | jq -rc '.updatedAt' | xargs date -u '+%s' -d)"
      if [ "$doc_dt" -ge "$file_dt" ]; then
        download_document "$uuid" "$title" </dev/null
      else
        upload_document "$uuid" "$title" </dev/null
      fi
    done
}

sync_1password

set +x

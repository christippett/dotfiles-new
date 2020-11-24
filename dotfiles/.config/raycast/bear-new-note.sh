#!/bin/bash

# Raycast Script Command Template
#
# Duplicate this file and remove ".template." from the filename to get started.
# See full documentation here: https://github.com/raycast/script-commands
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Add snippett to Bear
# @raycast.mode compact
#
# Optional parameters:
# @raycast.icon 📓
# @raycast.currentDirectoryPath ~
# @raycast.packageName Bear

source "$HOME/.asdf/asdf.sh"

id="1D2A01AB-AB5E-4DD7-8A8C-FD91F8F06EC4-329-00003C90359587D2"
date="$(date '+%A, %d %B %Y')"
time="$(date '+%I:%M%p' | tr '[:upper:]' '[:lower:]')"

header="$date"
text="$(printf '/%s/\n```\n%s\n```\n---\n' "$time" "$(pbpaste)")" # url encode text

if ! bear open-note "$id" | grep -iq "$header"; then
  bear add-text "### ${header}" --id "${id}" --new-line --mode=prepend --header="Snippets" >/dev/null 2>&1
fi

bear add-text "${text}" --id "${id}" --new-line --mode=prepend --header="$header" >/dev/null 2>&1

echo "Snippet added to Bear 🐨"

#!/bin/zsh

# avoid ubuntu calling compinit globally
# https://github.com/zdharma/zinit#disabling-system-wide-compinit-call-ubuntu
skip_global_compinit=1

# common install path used by package managers (ie. pipx)
PATH="$HOME/.local/bin:$PATH"


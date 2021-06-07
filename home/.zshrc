#!/bin/zsh

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

export WORDCHARS=''
export LESS="-RFi"
export PAGER="less -RFis"
export MANPAGER="sh -c $'col -bx | bat -f --italic-text --tabs 1 -l man'"

export BAT_PAGER="$LESS"
export BAT_THEME="Coldark-Dark"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="nvim"
else
  export EDITOR="nvim"
  export LESSEDIT="$EDITOR"
  export GIT_EDITOR="$EDITOR"
fi

bindkey -e # use emacs bindings even with vim as EDITOR

# PATH ----------------------------------------------------------------------- #

# homebrew
[ -d "/opt/homebrew" ] && PATH="/opt/homebrew/bin:$PATH"

# common install path used by package managers (ie. pipx)
PATH="$HOME/.local/bin:$PATH"

# EXA ------------------------------------------------------------------------ #
# https://the.exa.website/docs/colour-themes

read -r -d '' EXA_COLORS <<- "EOT"
	:sn=1;37:sb=37:
	:da=3;37:
	:un=33:uu=1;3;33:
	:ur=3;35:uw=3;35:ux=3;35:ue=3;35:
	:gr=3;32:gw=3;32:gx=3;32:
	:tr=3;31:tw=3;31:tx=3;31:
	:su=37:sf=37:xa=0;2;37:
	:xx=0;2;37:
EOT
export EXA_COLORS
export EXA_ICON_SPACING="2"

# FZF ------------------------------------------------------------------------ #

read -r -d '' FZF_DEFAULT_OPTS <<- "EOT"
	--height 90%
	--margin=0,3%,0,0
	--padding=1,0
	--layout=reverse
	--info=inline
	--prompt='  '
	--pointer='●'
	--marker='‣'
	--multi
	--preview-window='right:50:rounded:hidden'
	--preview '([[ -f {} && {} == *.json ]] && (cat {} | jq -M | bat -nf -l json)) || ([[ -f {} ]] && (bat -nf -m "config_*:dosini" {} || cat {})) || ([[ -d {} ]] && (exa --tree --icons {} | less)) || echo {} 2> /dev/null | head -200'
	--color=fg:7:dim,bg:-1,hl:7,border:7
	--color=fg+:7:bold,bg+:-1,hl+:1:underline
	--color=prompt:regular:0,pointer:7,marker:7,spinner:regular:3
	--color=info:1:underline,header:-1,query:3:underline:,disabled:1
	--color=preview-fg:-1,preview-bg:-1
	--bind '?:toggle-preview'
	--bind 'ctrl-a:select-all'
	--bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
	--bind 'ctrl-e:execute(echo {+} | xargs -o vim)'
	--bind 'ctrl-v:execute(code {+})'
	--bind 'ctrl-o:execute-silent(open "$(dirname {+})")'
EOT
export FZF_DEFAULT_OPTS
export FZF_DEFAULT_COMMAND="fd -H -E .git -E node_modules -E .Trash"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d --max-depth 3"
export FZF_ALT_C_OPTS="--preview 'exa -la --no-permissions --no-user --no-filesize --icons --no-time {}' --color=border:-1"

export LS_COLORS="di=1;36:ln=3;35:fi=37:so=32:pi=33:ex=1;4;37:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# ZINIT ---------------------------------------------------------------------- #
# https://zdharma.github.io/zinit/wiki/

declare -A ZINIT  # initial zinit config var
ZINIT[HOME_DIR]="$HOME/.zinit"
ZINIT[COMPINIT_OPTS]="-C"

if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
		print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
		command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
		command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
				print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
				print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
		zinit-zsh/z-a-rust \
		zinit-zsh/z-a-as-monitor \
		zinit-zsh/z-a-patch-dl \
		zinit-zsh/z-a-bin-gem-node

# ZINIT POST-INSTALL --------------------------------------------------------- #

setopt glob_dots
setopt promptsubst

# ZINIT PLUGINS -------------------------------------------------------------- #

# gui editor for zinit commands
zinit load zdharma/zui

# zsh-autosuggestions
zinit ice wait! lucid atload"!_zsh_autosuggest_start"
zinit load zsh-users/zsh-autosuggestions

# zsh-history-substring-search
# https://github.com/zsh-users/zsh-history-substring-search
zinit ice lucid; zinit load zsh-users/zsh-history-substring-search
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down


# fast-syntax-highlightinging
# https://github.com/zdharma/zinit#calling-compinit-with-turbo-mode
zinit ice wait lucid atinit"zicompinit; zicdreplay"
zinit light zdharma/fast-syntax-highlighting

# COMPLETIONS ---------------------------------------------------------------- #

# cd will never select the parent directory (e.g.: cd ../<TAB>):
zstyle ':completion:*:(cd|mv|cp):*' ignore-parents parent pwd
zstyle ':completion:*:*:vim:*' file-patterns '^*.(aux|log|pdf):source-files' '*:all-files'

zinit ice wait lucid atload"zicompinit; zicdreplay" blockf for zsh-users/zsh-completions

# oh-my-zsh plugins
zinit wait"4" lucid as"completion" for \
	OMZP::docker/_docker \
	OMZP::pip/_pip

# yq
zinit ice wait"4" lucid id-as"yq" from"gh-r" as"program" \
	mv"yq* -> yq" pick"yq" \
	atload'yq shell-completion zsh > _yq'
zinit light mikefarah/yq

# gcloud
export CLOUDSDK_HOME="$HOME/.google-cloud-sdk"
zinit snippet OMZP::gcloud

# CLI TOOLS ------------------------------------------------------------------ #

zinit wait lucid for \
      OMZP::colored-man-pages \
      OMZP::cp \
      OMZP::fancy-ctrl-z \
      OMZP::git \
      OMZP::sudo \
			blockf rupa/z \
      aloxaf/fzf-tab \
      wfxr/forgit

zinit wait lucid as"program" for \
	from"gh-r" sbin"**/fd"							@sharkdp/fd \
	from"gh-r" sbin"**/bat"							@sharkdp/bat \
	from"gh-r" sbin"**/exa"							ogham/exa \
	from"gh-r" bpick"*darwin_arm64*"		junegunn/fzf \
	from"gh-r" mv"jq-* -> jq" pick"jq"	stedolan/jq \
	pick"bin/git-dsf"										zdharma/zsh-diff-so-fancy

# fzf
zinit snippet "https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh"

# asdf
zinit ice lucid as"program" \
	pick"bin/asdf" src="asdf.sh" \
	atload'PIPX_DEFAULT_PYTHON="$(asdf which python)"'
zinit load @asdf-vm/asdf

# starship prompt
# https://starship.rs/config/
zinit ice lucid as"program" from"gh-r" \
	bpick"*aarch64*apple*" \
  atclone'starship completions > "_starship"' \
	atpull'%atclone' \
	atload'eval "$(starship init zsh)"'
zinit load starship/starship

# ---------------

# delete google cloud credentials older than 3 hours
find "$HOME/.config/gcloud" -type f -name "application_default_credentials.json" \
  -mmin +180 -exec rm -f {} \;

# zinit ice wait notify nocompletions; zinit snippet "$HOME/.iterm2_shell_integration.zsh"
zinit snippet "$HOME/.dotfiles/scripts/utils.sh"
zinit snippet "$HOME/.aliases"



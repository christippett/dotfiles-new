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
setopt glob_dots
setopt promptsubst

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

export WORDCHARS=''
export LESS="-RFSi -j.3"
export PAGER="less ${LESS} -s"
export SYSTEMD_LESS="$LESS -SM"
export PAGER="less $LESS"
export BAT_PAGER="$LESS"
export MANPAGER="sh -c 'col -bx | bat --pager \"\$PAGER\" -f --italic-text --style=plain --tabs=1 -l=man'"

#export BAT_THEME="Coldark-Dark"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="nvim"
else
  export EDITOR="nvim"
  export LESSEDIT="$EDITOR"
  export GIT_EDITOR="$EDITOR"
fi

bindkey -e # use emacs bindings even with vim as EDITOR

# PATH ----------------------------------------------------------------------- #

# common install path used by package managers (ie. pipx)
PATH="$HOME/.local/bin:$PATH"
test -d "/opt/homebrew" && PATH="/opt/homebrew/bin:$PATH"

# EXA ------------------------------------------------------------------------ #
# https://the.exa.website/docs/colour-themes

read -r -d '' EXA_COLORS <<- "EOT"
	:sn=1;37:sb=37:
	:da=37:
	:un=33:uu=1;3;31:
	:gn=33:gu=31:
	:ur=35:uw=35:ux=35:ue=35:
	:gr=32:gw=32:gx=32:
	:tr=31:tw=31:tx=31:
	:su=37:sf=37:xa=0;2;37:
	:xx=0;2;37:
	:lp=2;35:
EOT
export EXA_COLORS
export EXA_ICON_SPACING="1"

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



# 🚀 zsh-snap ---------------------------------------------------------------- #

# start znap
source "$HOME/.local/share/zsh-snap/znap.zsh"

# start starship prompt
znap eval starship 'starship init zsh --print-full-init'
#znap prompt

# 🤠 user config-------------------------------------------------------------- #

# user scripts
source ~/.aliases
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# zsh config
zstyle ':completion:*' menu select
zstyle ':completion:*:(cd|mv|cp):*' ignore-parents parent pwd # ignore parent directory when cd ../<TAB>
zstyle ':completion:*:*:vim:*' file-patterns '^*.(aux|log|pdf):source-files' '*:all-files'

zstyle ':autocomplete:*' fzf-completion yes
zstyle ':autocomplete:*' min-input 3

# 🐢 shell utilities---------------------------------------------------------- #

#if command -v brew; then
#	znap eval brew_bundle 'brew bundle install ~/.Brewfile'
#else
#	sudo sh -c i
#	znap eval apt_install <<EOT
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64;
#add-apt-repository ppa:rmescandon/yq;
#apt update && apt install yq -y
#EOT
#fi

znap install so-fancy/diff-so-fancy
znap install junegunn/fzf
znap source mbhynes/fzf-gcloud fzf-gcloud.plugin.zsh
znap source rupa/z z.sh
znap eval fzf-bindings "curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh"
znap eval fancy-ctrl-z "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/fancy-ctrl-z/fancy-ctrl-z.plugin.zsh"

#znap source marlonrichert/zcolors
#znap eval zcolors "zcolors ${(q)LS_COLORS}"

# 🪠  zsh plugins ------------------------------------------------------------- #

# znap source marlonrichert/zsh-edit
znap source junegunn/fzf shell/completion.zsh shell/key-bindings.zsh
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-syntax-highlighting
znap source marlonrichert/zsh-autocomplete
bindkey $key[Down] down-line-or-select
bindkey $key[Up] up-line-or-search

# znap source zsh-users/zsh-history-substring-search
# bindkey "^[[A" history-substring-search-up
# bindkey "^[[B" history-substring-search-down

# 📋 zsh completions --------------------------------------------------------- #

znap compdef _poetry 'poetry completions zsh'
znap eval yq-completions 'yq shell-completion zsh'
znap eval pip-completion 'pip completion --zsh'
znap eval pipx-completion 'register-python-argcomplete pipx'
znap source aws/aws-cli bin/aws_zsh_completer.sh

fpath+=(
  ~[asdf-vm/asdf]/completions
  ~[asdf-community/asdf-direnv]/completions
  ~[zsh-users/zsh-completions]/src
  ~[sharkdp/fd]/contrib/completion
)

test -n "${HOMEBREW_PREFIX}" && fpath+=( "$HOMEBREW_PREFIX/share/zsh/site-functions" )

# 🚧 TODO -------------------------------------------------------------------- #
#
#   - script installation of brew formulas/casks
#   - script installation of asdf plugins
#   - script installation of pipx packages

# show neofetch when everything's done 🧮
neofetch --source ~/.dotfiles/home/.config/neofetch/tennis.txt --ascii_colors 1 2 3 4 5 6


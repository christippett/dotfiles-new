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
export MANPAGER="sh -c 'col -bx | bat --pager \"\$PAGER\" -f --italic-text --style=plain --tabs=1 -l=man'"
export BAT_PAGER="$LESS"
#export BAT_THEME="Coldark-Dark"

export SSH_AUTH_SOCK="$HOME/Library/Containers/org.hejki.osx.sshce.agent/Data/socket.ssh"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="nvim"
else
  export EDITOR="nvim"
  export LESSEDIT="$EDITOR"
  export GIT_EDITOR="$EDITOR"
fi

bindkey -e # use emacs bindings even with vim as EDITOR

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
--padding=0,0
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

# search only git directories
# export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d --max-depth 3"
export FZF_ALT_C_COMMAND="fd --type d -H '^\.git$' --exec dirname"
export FZF_ALT_C_OPTS="--preview 'exa -la --no-permissions --no-user --no-filesize --icons --no-time {}' --color=border:-1"

# PATH ----------------------------------------------------------------------- #

# common install path used by package managers (ie. pipx)
PATH="$HOME/.local/bin:$PATH"
test -d "/opt/homebrew" && PATH="/opt/homebrew/bin:$PATH"

# GCLOUD --------------------------------------------------------------------- #

export CLOUDSDK_HOME="$HOME/.local/google-cloud-sdk"
if [[ -d CLOUDSDK_HOME ]]; then
	CLOUDSDK_INSTALL_DIR="$(dirname $CLOUDSDK_HOME)"
	CLOUDSDK_CORE_DISABLE_PROMPTS=1
	mkdir -p $CLOUDSDK_HOME
	curl -fsSL https://sdk.cloud.google.com | bash
else
	source $CLOUDSDK_HOME/completion.zsh.inc
	source $CLOUDSDK_HOME/path.zsh.inc
fi

# 🛸 zsh-snap ---------------------------------------------------------------- #

# start znap, install if necessary
ZNAP_DIR="$HOME/.local/share/zsh-snap"

if [[ ! -f "$ZNAP_DIR/znap.zsh" ]]; then
	git clone https://github.com/marlonrichert/zsh-snap.git "$ZNAP_DIR"
else
	source "$ZNAP_DIR/znap.zsh"
fi

# 🚀 prompt ------------------------------------------------------------------ #

# run neofetch prior to initial prompt
neofetch --source "$HOME/.dotfiles/home/.config/neofetch/$(hostname -s).txt" --ascii_colors 1 2 3 4 5 6

# start starship prompt
znap eval starship 'starship init zsh --print-full-init'
#znap prompt # BUG: causes issue with starship and $pipestatus

# 🤠 user config-------------------------------------------------------------- #

# zsh config
zstyle ':completion:*' menu select
zstyle ':completion:*:(cd|mv|cp):*' ignore-parents parent pwd # ignore parent directory when cd ../<TAB>
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:*:vim:*' file-patterns '^*.(aux|log|pdf):source-files' '*:all-files'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':fzf-tab:complete:(cd|mv|cp|ls):*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:complete:docker-*:*' fzf-preview '(docker inspect $word | jq -C)'
zstyle ':fzf-tab:complete:docker-logs:*' fzf-preview '(docker logs $word | less)'
zstyle ':fzf-tab:complete:gcloud:*' fzf-preview '((gcloud $word --help 2>/dev/null || gcloud help) | sed "s/  / /g")'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

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
znap source asdf-vm/asdf asdf.sh
# znap source mbhynes/fzf-gcloud fzf-gcloud.plugin.zsh
znap source rupa/z z.sh
znap eval trapd00r/LS_COLORS "$( whence -a dircolors gdircolors ) -b LS_COLORS"
znap eval fzf-bindings "curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh"
znap eval fancy-ctrl-z "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/fancy-ctrl-z/fancy-ctrl-z.plugin.zsh"
znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

#znap source marlonrichert/zcolors
#znap eval zcolors "zcolors ${(q)LS_COLORS}"

# 🪠  zsh plugins ------------------------------------------------------------- #

znap source junegunn/fzf shell/completion.zsh shell/key-bindings.zsh

znap source Aloxaf/fzf-tab fzf-tab.plugin.zsh

ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting

ZSH_AUTOSUGGEST_STRATEGY=( history )
znap source zsh-users/zsh-autosuggestions

znap source zsh-users/zsh-history-substring-search
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down


# 📋 zsh completions --------------------------------------------------------- #

znap compdef _cloud_sql_proxy 'curl -Ls https://raw.githubusercontent.com/zchee/zsh-completions/main/src/zsh/_cloud_sql_proxy'
znap compdef _docker 'curl -Ls https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker'
znap compdef _docker-compose 'curl -Ls https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/zsh/_docker-compose'
znap compdef _poetry 'poetry completions zsh'
znap compdef _cargo 'rustup completions zsh cargo'
znap fpath _yq 'yq shell-completion zsh'
znap eval pip-completion 'pip completion --zsh'
znap eval pipx-completion 'register-python-argcomplete pipx'
znap source aws/aws-cli bin/aws_zsh_completer.sh

fpath+=(
  ~[sharkdp/fd]/contrib/completion
  ~[asdf-vm/asdf]/completions
  ~[asdf-community/asdf-direnv]/completions
  ~[zsh-users/zsh-completions]/src
)

test -n "${HOMEBREW_PREFIX}" && fpath+=( "$HOMEBREW_PREFIX/share/zsh/site-functions" )

# 🚧 TODO -------------------------------------------------------------------- #
#
#   - script installation of brew formulas/casks
#   - script installation of asdf plugins
#   - script installation of pipx packages

source eval aliases 'source ~/.aliases'


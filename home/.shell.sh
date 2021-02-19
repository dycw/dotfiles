#!/usr/bin/env bash

# shellcheck disable=SC1091,SC2139,SC2140,SC2181
# shellcheck source=/dev/null

__shell="$1"

# === system ==
# dotfiles
export PATH_DOTFILES="${PATH_DOTFILES:-$HOME/dotfiles}"
__shell_local_sh="$HOME/.shell.local.sh" && [ -f "$__shell_local_sh" ] && source "$__shell_local_sh" zsh

# homebrew
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH:+:$PATH}"
export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH:+:$MANPATH}:"
export INFOPATH="/home/linuxbrew/.linuxbrew/share/info${INFOPATH:+:$INFOPATH}"
__brew_dir=/home/linuxbrew_dir/.linuxbrew_dir/bin/brew_dir && [ -f "$__brew_dir" ] && eval "$("$__brew_dir" shellenv)"

# XDG
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$USER}"

# === applications ===
# atom
(command -v atom >/dev/null 2>&1) && export GIST_ID=690a59ef26208e43fa880c874e01c1

# bash
alias bashrc='$EDITOR $HOME/.bashrc'

# bat
if command -v bat >/dev/null 2>&1; then
	alias cat='bat'
	alias catp='bat --style=plain'
	tf() { tail -f "$1" | bat --paging=never -l log; }
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# batgrep
(command -v batgrep >/dev/null 2>&1) && alias bg='batgrep'

# bin
while IFS= read -d '' -r __bin; do
	export PATH="$__bin${PATH:+:$PATH}"
done < <(find "$PATH_DOTFILES" -name bin -print0 -type d)

# cargo
__cargo_bin="$HOME/.cargo/bin" && [ -d "$__cargo_bin" ] && export PATH="$__cargo_bin${PATH:+:$PATH}"

# cd
alias ~='cd $HOME'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias cddf='cd $PATH_DOTFILES'
alias cddl='cd $HOME/Downloads'
alias cddt='cd $HOME/Desktop'
alias cdp='cd $HOME/Pictures'
alias cdw='cd $HOME/work'

# conda
__miniconda3="$HOME/miniconda3"
if [ -d "$__miniconda3" ]; then
	__conda_bin="$__miniconda3/bin"
	__conda_setup="$("$__conda_bin/conda" "shell.$__shell" 'hook' 2>/dev/null)"
	if [ $? -eq 0 ]; then
		eval "$__conda_setup"
	else
		__conda_sh="$__miniconda3/etc/profile.d/conda.sh"
		if [ -f "$__conda_sh" ]; then
			. "$__conda_sh"
		else
			export PATH="$__conda_bin${PATH:+:$PATH}"
		fi
	fi
	unset __conda_setup
fi

# direnv
(command -v direnv >/dev/null 2>&1) && eval "$(direnv hook "$__shell")"

# dropbox
if command -v dropbox.py >/dev/null 2>&1; then
	dropbox.py autostart yes
	dropbox.py start >/dev/null 2>&1
	__path_dropbox=/data/derek/Dropbox
	if [ -d "$__path_dropbox" ]; then
		alias cddb='cd $PATH_DROPBOX'
		export PATH_DROPBOX="$__path_dropbox"
	fi
fi

# fd
if command -v fd >/dev/null 2>&1; then
	alias fdd='fd --type=directory'
	alias fde='fd --type=executable'
	alias fdf='fd --type=file'
	alias fds='fd --type=symlink'
fi

# exa
if command -v exa >/dev/null 2>&1; then
	__exa_base() { exa -F --group-directories-first "$@"; }
	__exa_short() { __exa_base -x "$@"; }
	l() { __exa_short --git-ignore "$@"; }
	la() { __exa_short -a "$@"; }
	__exa_long() { __exa_base -ghl --git --time-style=long-iso "$@"; }
	ll() { __exa_long --git-ignore "$@"; }
	lla() { __exa_long -a "$@"; }
	lal() { lla "$@"; }
fi

# fzf
__fzf_shell="$XDG_CONFIG_HOME/fzf/fzf.$__shell"
if [ -f "$__fzf_shell" ]; then
	source "$__fzf_shell"
	if (command -v bat >/dev/null 2>&1) &&
		(command -v fd >/dev/null 2>&1) &&
		(command -v tree >/dev/null 2>&1); then
		# https://bit.ly/2OMLMpm
		export FZF_DEFAULT_COMMAND='fd -HL -c=always -E=.git -E=node_modules'
		export FZF_DEFAULT_OPTS="
      --ansi
      --bind 'ctrl-a:select-all'
      --bind 'ctrl-e:execute(echo {+} | xargs -o vim)'
      --bind 'ctrl-v:execute(code {+})'
      --bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
      --color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'
      --height=80%
      --info=inline
      --layout=reverse
      --multi
      --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
      --preview-window 'right:60%:wrap'
      --prompt='∼ ' --pointer='▶' --marker='✓'
      "
		export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -t=f -t=d"
		export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND -t=d"
	fi
fi

# git
alias cdr='cd $(git root)'
alias gitconfig='$EDITOR $XDG_CONFIG_HOME/git/config'
alias gitignore='$EDITOR $XDG_CONFIG_HOME/git/ignore'
for al in $(git --list-cmds=alias); do
	alias "g$al"="git $al"
done

# gitweb
(command -v gitweb >/dev/null 2>&1) && alias gw='gitweb'

# googler
(command -v googler >/dev/null 2>&1) && alias g='googler'

# nvim
if command -v nvim >/dev/null 2>&1; then
	alias n='nvim'
	alias v='nvim'
	alias vim='nvim'
	alias vimrc='$EDITOR $XDG_CONFIG_HOME/nvim/init.vim'
	export EDITOR=nvim
fi

# pre-commit
if command -v python >/dev/null 2>&1; then
	alias pc='pre-commit-current'
	alias pci='pre-commit install'
	alias pcaf='pre-commit run --all-files'
	alias pcau='pre-commit autoupdate'
	alias pcui='pre-commit uninstall'
fi

# python: flask
(command -v python >/dev/null 2>&1) && export FLASK_DEBUG=1

# python: hypothesis
if command -v python >/dev/null 2>&1; then
	alias hypothesis-ci='export HYPOTHESIS_PROFILE=ci'
	alias hypothesis-debug='export HYPOTHESIS_PROFILE=debug'
	alias hypothesis-default='export HYPOTHESIS_PROFILE=default'
	alias hypothesis-dev='export HYPOTHESIS_PROFILE=dev'
fi

# python: numpy
(command -v python >/dev/null 2>&1) && export MKL_NUM_THREADS=1

# python: tensorboard
(command -v python >/dev/null 2>&1) && alias tb='tensorboard --logdir .'

# rg
(command -v rg >/dev/null 2>&1) && alias rg='rg --no-messages'

# sh
alias shellsh='$EDITOR $HOME/.shell.sh'

# starship
if command -v starship >/dev/null 2>&1; then
	alias starshiptoml='$EDITOR $XDG_CONFIG_HOME/starship.toml'
	eval "$(starship init "$__shell")"
fi

# tmux
(command -v tmux >/dev/null 2>&1) && alias tmuxconf='$EDITOR $HOME/.tmux.conf.local'

# ubuntu (https://askubuntu.com/a/492343)
alias apt-installed="comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"

# vim-superman
__bin="$HOME/.local/share/nvim/plugged/vim-superman/bin" && [ -d "$__bin" ] && export PATH="$__bin${PATH:+:$PATH}"

# xclip
if command -v xclip >/dev/null 2>&1; then
	alias pbcopy='xclip -selection clipboard'
	alias pbpaste='xclip -selection clipboard -o'
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
	export _ZO_EXCLUDE_DIRS="/tmp"
	export _ZO_RESOLVE_SYMLINKS=1
	eval "$(zoxide init "$__shell" --cmd=c)"
fi

# zsh
alias zshrc='$EDITOR $HOME/.zshrc'

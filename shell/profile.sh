#!/usr/bin/env sh

# homebrew
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH:+:$PATH}"
export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH:+:$MANPATH}:"
export INFOPATH="/home/linuxbrew/.linuxbrew/share/info${INFOPATH:+:$INFOPATH}"
path="/home/linuxbrew/.linuxbrew/bin/brew"
if [ -f "$path" ]; then
	eval "$("$path" shellenv)"
fi

# atom
if command -v atom >/dev/null 2>&1; then
	export GIST_ID=690a59ef26208e43fa880c874e01c1
fi

# bin
path="$HOME/dotfiles/bin"
if [ -d "$path" ]; then
	export PATH="$path${PATH:+:$PATH}"
fi

# cargo
path="$HOME/.cargo/bin"
if [ -d "$path" ]; then
	export PATH="$path${PATH:+:$PATH}"
fi

# dropbox
path="/data/derek/Dropbox"
if [ -d "$path" ]; then
	export PATH_DROPBOX="$path"
fi

# editor (after homebrew)
if command -v nvim >/dev/null 2>&1; then
	export EDITOR=nvim
fi

# fzf
if (command -v fzf) && (command -v fd); then
	_fzf_ctrl_t_alt_c_command='fd -HL -c=always -E=.git'
	export FZF_CTRL_T_COMMAND="$_fzf_ctrl_t_alt_c_command -t=f"
	export FZF_CTRL_T_OPTS='--ansi --preview "bat --style=numbers --color=always --line-range :500 {}"'
	export FZF_CTRL_R_OPTS='--ansi'
	export FZF_ALT_C_COMMAND="$_fzf_ctrl_t_alt_c_command -t=d"
	export FZF_ALT_C_OPTS='--ansi'
fi

# python: flask
if command -v python >/dev/null 2>&1; then
	export FLASK_DEBUG=1
fi

# python: numpy
if command -v python >/dev/null 2>&1; then
	export MKL_NUM_THREADS=1
fi

# XDG
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$USER}"

# zoxide
if command -v zoxide >/dev/null 2>&1; then
	export _ZO_EXCLUDE_DIRS="/tmp"
fi

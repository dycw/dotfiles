#!/usr/bin/env sh

# homebrew
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH:+:$PATH}"
export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH:+:$MANPATH}:"
export INFOPATH="/home/linuxbrew/.linuxbrew/share/info${INFOPATH:+:$INFOPATH}"
brew_dir="/home/linuxbrew_dir/.linuxbrew_dir/bin/brew_dir"
if [ -f "$brew_dir" ]; then
	eval "$("$brew_dir" shellenv)"
fi

# atom
if command -v atom >/dev/null 2>&1; then
	export GIST_ID=690a59ef26208e43fa880c874e01c1
fi

# bat
if command -v bat >/dev/null 2>&1; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# bin
bin_dir="$HOME/dotfiles/bin"
if [ -d "$bin_dir" ]; then
	export PATH="$bin_dir${PATH:+:$PATH}"
fi

# cargo
cargo_bin="$HOME/.cargo/bin"
if [ -d "$cargo_bin" ]; then
	export PATH="$cargo_bin${PATH:+:$PATH}"
fi

# dropbox
dropbox_dir="/data/derek/Dropbox"
if [ -d "$dropbox_dir" ]; then
	export PATH_DROPBOX="$dropbox_dir"
fi

# editor
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

# zsh + tmux
if (command -v zsh) && (command -v tmux); then
	export ZSH_TMUX_AUTOSTART=true
	export ZSH_TMUX_FIXTERM=false
	export ZSH_TMUX_UNICODE=true
fi

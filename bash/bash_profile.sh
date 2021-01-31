#!/usr/bin/env bash
# shellcheck disable=SC1090

export EDITOR=vim
export FLASK_DEBUG=1
export GIST_ID=690a59ef26208e43fa880c874e01c18c
export MKL_NUM_THREADS=1
export PATH_DROPBOX="/data/derek/Dropbox"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$USER}"

# https://unix.stackexchange.com/a/541352
if [ -n "$BASH_VERSION" ]; then
	# include .bashrc if it exists
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
fi

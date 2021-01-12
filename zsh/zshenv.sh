#!/usr/bin/env sh

export EDITOR=vim
export FLASK_DEBUG=1
export MKL_NUM_THREADS=1
export PATH="$HOME/.dotfiles/bin${PATH:+:${PATH}}"
export PATH_DROPBOX="/data/derek/Dropbox"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$USER}"

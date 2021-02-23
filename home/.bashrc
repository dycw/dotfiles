#!/usr/bin/env bash
# shellcheck source=/dev/null

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

__config_sh="$XDG_CONFIG_HOME/shell/config.sh"
if [ -f "$__config_sh" ]; then
	source "$__config_sh" bash
fi
__bashrc_local="$XDG_CONFIG_HOME/bash/bashrc.local.sh"
if [ -f "$__bashrc_local" ]; then
	source "$__bashrc_local"
fi

# bash
__bash="$XDG_CACHE_HOME/bash"
mkdir -p "$__bash"
HISTCONTROL=ignoreboth
HISTFILE="$__bash/bash_history"
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s autocd
shopt -s cdspell
shopt -s checkjobs
shopt -s checkwinsize
shopt -s direxpand
shopt -s dotglob
shopt -s extglob
shopt -s globstar
shopt -s histappend
shopt -s nocaseglob
shopt -s nocasematch
shopt -s shift_verbose
shopt -s xpg_echo

# vim-superman
if command -v vman >/dev/null 2>&1; then
	complete -o default -o nospace -F _man vman
fi

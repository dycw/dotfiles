#!/usr/bin/env bash
# shellcheck source=/dev/null

__shell_sh="$HOME/.shell.sh"
if [ -f "$__shell_sh" ]; then
	source "$__shell_sh" bash
fi
__bashrc_local="$HOME/.bashrc.local"
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
(command -v vman >/dev/null 2>&1) && complete -o default -o nospace -F _man vman

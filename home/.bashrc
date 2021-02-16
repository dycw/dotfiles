#!/usr/bin/env bash
# shellcheck source=/dev/null

__shell_sh="$HOME/.shell.sh" && [ -f "$__shell_sh" ] && source "$__shell_sh" bash
__bashrc_local="$HOME/.bashrc.local" && [ -f "$__bashrc_local" ] && source "$__bashrc_local"

# bash
HISTCONTROL=ignoreboth
HISTFILE="$XDG_CACHE_HOME/bash/bash_history"
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

#!/usr/bin/env bash
# shellcheck source=/dev/null

[ -f "$HOME/dotfiles/shell/rc.sh" ] && source "$HOME/dotfiles/shell/rc.sh" bash

# bash
HISTCONTROL=ignoreboth
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/bash/bash_history"
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

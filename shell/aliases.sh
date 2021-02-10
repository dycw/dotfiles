#!/usr/bin/env bash

alias ~="cd ~"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias cddf="cd ~/.dotfiles"
alias cddl="cd ~/Downloads"
alias cddt="cd ~/Desktop"
alias cdp="cd ~/Pictures"
alias cdw="cd ~/work"

if ! command -v exa >/dev/null 2>&1; then
	alias l="ls --classify --color=always --group-directories-first"
	alias la="l --almost-all"
	alias ll="l -l"
	alias lla="ll --almost-all"
	alias lal="lla"
fi

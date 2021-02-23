#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck source=/dev/null

__shell_sh="$HOME/.shell.sh"
if [ -f "$__shell_sh" ]; then
	source "$__shell_sh" zsh
fi
__zinit_sh="$HOME/.zinit.sh"
if [ -f "$__zinit_sh" ]; then
	source "$__zinit_sh"
fi
__zshrc_local="$HOME/.zshrc.local"
if [ -f "$__zshrc_local" ]; then
	source "$__zshrc_local"
fi

# compinstall
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit

# settings: history
__zsh="$XDG_CACHE_HOME/zsh"
mkdir -p "$__zsh"
export HISTFILE="$__zsh/histfile"
export HISTSIZE=10000
export SAVEHIST=10000

# settings: opts
setopt autocd
setopt extendedglob
setopt nomatch
setopt notify
unsetopt beep
bindkey -v

# plugins: fzf
zinit load Aloxaf/fzf-tab # after compinit, but before others

# plugins: autocompletion
zinit load zsh-users/zsh-autosuggestions
zinit load zsh-users/zsh-completions

# plugins: completion
zinit load esc/conda-zsh-completion
zinit snippet OMZP::ubuntu
zinit load lukechilds/zsh-better-npm-completion
zinit load zchee/zsh-completions

# plugins: editing
zinit load zdharma/fast-syntax-highlighting
zinit snippet OMZP::sudo
zinit load hlissner/zsh-autopair
zinit load mtxr/zsh-change-case
bindkey '^K^U' _mtxr-to-upper # Ctrl+K + Ctrl+U
bindkey '^K^L' _mtxr-to-lower # Ctrl+K + Ctrl+L
zinit load jeffreytse/zsh-vi-mode

# plugins: git
zinit snippet OMZP::git-auto-fetch
export GIT_AUTO_FETCH_INTERVAL=60

# plugins: navigation
zinit snippet OMZP::zsh-interactive-cd

# plugins: tmux
zinit snippet OMZP::tmux
if command -v tmux >/dev/null 2>&1; then
	export ZSH_TMUX_AUTOSTART=true
	export ZSH_TMUX_FIXTERM=false
	export ZSH_TMUX_UNICODE=true
fi

# vim-superman
if command -v vman >/dev/null 2>&1; then
	compdef vman="man"
fi

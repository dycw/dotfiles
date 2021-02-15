#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck source=/dev/null

[ -f "$HOME/dotfiles/shell/rc.sh" ] && source "$HOME/dotfiles/shell/rc.sh" zsh
[ -f "$HOME/dotfiles/shell/zinit.sh" ] && source "$HOME/dotfiles/shell/zinit.sh"

# compinstall
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit

# settings: history
export HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.histfile"
export HISTSIZE=10000
export SAVEHIST=10000

# settings: opts
setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -v

# plugins: autocompletion
zinit load marlonrichert/zsh-autocomplete
zstyle ':autocomplete:*' min-input 1

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

# plugins: git
zinit snippet OMZP::git-auto-fetch

# plugins: navigation
zinit snippet OMZP::zsh-interactive-cd

zinit load nviennot/zsh-vim-plugin

# plugins: tmux
zinit snippet OMZP::tmux
if (command -v tmux >/dev/null 2>&1); then
	export ZSH_TMUX_AUTOSTART=true
	export ZSH_TMUX_FIXTERM=false
	export ZSH_TMUX_UNICODE=true
fi

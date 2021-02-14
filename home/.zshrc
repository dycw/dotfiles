# shellcheck shell=bash
# shellcheck source=/dev/null

rc="$HOME/dotfiles/shell/rc.sh"
if [ -f "$rc" ]; then
	source "$rc" zsh
fi

zshrc_managed="$HOME/dotfiles/shell/zshrc-managed.zsh"
if [ -f "$zshrc_managed" ]; then
	source "$zshrc_managed"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
export HISTSIZE=10000
export SAVEHIST=10000
setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

zinit load zdharma/fast-syntax-highlighting
zinit load zdharma/history-search-multi-word
zinit load zsh-users/zsh-autosuggestions
zinit load zsh-users/zsh-completions

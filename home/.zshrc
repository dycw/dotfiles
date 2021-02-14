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

# plugins: autocompletion
zinit load marlonrichert/zsh-autocomplete
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:tab:*' insert-unambiguous yes
zstyle ':autocomplete:tab:*' fzf-completion yes

zinit load zsh-users/zsh-autosuggestions

zinit load zsh-users/zsh-completions

# plugins: completion
zinit load esc/conda-zsh-completion

zinit load srijanshetty/zsh-pip-completion

zinit snippet OMZP::ubuntu

# plugins: editing
zinit load zdharma/fast-syntax-highlighting

zinit load hlissner/zsh-autopair

zinit load mtxr/zsh-change-case
bindkey '^K^U' _mtxr-to-upper # Ctrl+K + Ctrl+U
bindkey '^K^L' _mtxr-to-lower # Ctrl+K + Ctrl+L

# plugins: navigation
zinit load desyncr/auto-ls
auto-ls-ls() { l; }
auto-ls-git-status() { [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == true ]] && gs; }

zinit snippet OMZP::zsh-interactive-cd

# Oh-my-zsh plugins
zinit snippet OMZP::alias-finder
zinit snippet OMZP::git-auto-fetch
zinit snippet OMZP::sudo
zinit snippet OMZP::tmux

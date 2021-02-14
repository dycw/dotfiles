# shellcheck disable=SC1091,SC2139,SC2140,SC2181
# shellcheck shell=bash
# shellcheck source=/dev/null

# bash
alias bash_profile='$EDITOR ~/.bash_profile'
alias bashrc='$EDITOR ~/.bashrc'

# bat
if command -v bat >/dev/null 2>&1; then
	alias cat="bat"
	alias catp="bat --style=plain"
	tf() { tail -f "$1" | bat --paging=never -l log; }
fi

# cd
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias cddf='cd $HOME/dotfiles'
alias cddl='cd $HOME/Downloads'
alias cddt='cd $HOME/Desktop'
alias cdp='cd $HOME/Pictures'
alias cdw='cd $HOME/work'

# direnv
if command -v direnv >/dev/null 2>&1; then
	eval "$(direnv hook "$0")"
fi

# dropbox
if command -v dropbox.py >/dev/null 2>&1; then
	dropbox.py autostart yes
	dropbox.py start >/dev/null 2>&1
	if [ -n "$PATH_DROPBOX" ]; then
		alias cddb='cd $PATH_DROPBOX'
	fi
fi

# fd
if command -v fd >/dev/null 2>&1; then
	alias fdd='fd --type=directory'
	alias fde='fd --type=executable'
	alias fdf='fd --type=file'
	alias fds='fd --type=symlink'
fi

# exa
if command -v exa >/dev/null 2>&1; then
	_exa_base() { exa -F --group-directories-first "$@"; }
	_exa_short() { _exa_base -x "$@"; }
	l() { _exa_short --git-ignore "$@"; }
	la() { _exa_short -a "$@"; }
	_exa_long() { _exa_base -ghl --git --time-style=long-iso "$@"; }
	ll() { _exa_long --git-ignore "$@"; }
	lla() { _exa_long -a "$@"; }
	lal() { lla "$@"; }
fi

# fzf
path="$HOME/.fzf.$0"
if [ -f "$path" ]; then
	source "$path"
fi

# git
alias cdr='cd $(git root)'
alias gitconfig='$EDITOR $XDG_CONFIG_HOME/git/config'
alias gitignore='$EDITOR $XDG_CONFIG_HOME/git/ignore'
for al in $(git --list-cmds=alias); do
	alias "g$al"="git $al"
done

# gitweb
if command -v gitweb >/dev/null 2>&1; then
	alias gw='gitweb'
fi

# googler
if command -v googler >/dev/null 2>&1; then
	alias g='googler'
fi

# npm
if command -v npm >/dev/null 2>&1; then
	source <(npm completion)
fi

# nvim
if command -v nvim >/dev/null 2>&1; then
	alias v='nvim'
	alias vim='nvim'
	alias vimrc='$EDITOR $XDG_CONFIG_HOME/nvim/init.vim'
fi

# pre-commit
if command -v python >/dev/null 2>&1; then
	alias pc='pre-commit-current'
	alias pci='pre-commit install'
	alias pcaf='pre-commit run --all-files'
	alias pcau='pre-commit autoupdate'
	alias pcui='pre-commit uninstall'
fi

# python: hypothesis
if command -v python >/dev/null 2>&1; then
	alias hypothesis-ci='export HYPOTHESIS_PROFILE=ci'
	alias hypothesis-debug='export HYPOTHESIS_PROFILE=debug'
	alias hypothesis-default='export HYPOTHESIS_PROFILE=default'
	alias hypothesis-dev='export HYPOTHESIS_PROFILE=dev'
fi

# python: tensorboard
if command -v python >/dev/null 2>&1; then
	alias tb='tensorboard --logdir .'
fi

# sh
alias shprofile='$EDITOR $HOME/dotfiles/shell/profile'
alias shrc='$EDITOR $HOME/dotfiles/shell/rc'

# starship
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init "$0")"
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
	alias tmuxconf='$EDITOR ~/.tmux.conf'
fi

# zsh
alias zprofile='$EDITOR ~/.zprofile'
alias zshrc='$EDITOR ~/.zshrc'

# zoxide
if command -v zoxide >/dev/null 2>&1; then
	eval "$(zoxide init "$0")"
fi

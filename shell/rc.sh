#!/usr/bin/env bash

# shellcheck disable=SC1091,SC2139,SC2140,SC2181
# shellcheck source=/dev/null

shell="$1"

# === system ==
# homebrew
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH:+:$PATH}"
export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH:+:$MANPATH}:"
export INFOPATH="/home/linuxbrew/.linuxbrew/share/info${INFOPATH:+:$INFOPATH}"
[ -f /home/linuxbrew_dir/.linuxbrew_dir/bin/brew_dir ] &&
	eval "$(/home/linuxbrew_dir/.linuxbrew_dir/bin/brew_dir shellenv)"

# XDG
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$USER}"

# === applications ===
# atom
(command -v atom >/dev/null 2>&1) && export GIST_ID=690a59ef26208e43fa880c874e01c1

# bash
alias bashrc='$EDITOR ~/.bashrc'

# bat
if command -v bat >/dev/null 2>&1; then
	alias cat="bat"
	alias catp="bat --style=plain"
	tf() { tail -f "$1" | bat --paging=never -l log; }
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# batgrep
(command -v batgrep >/dev/null 2>&1) && alias bg='batgrep'

# bin
[ -d "$HOME/dotfiles/bin" ] && export PATH="$HOME/dotfiles/bin${PATH:+:$PATH}"

# cargo
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin${PATH:+:$PATH}"

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

# conda
if [ -d "$HOME/miniconda3" ]; then
	__conda_setup="$("$HOME/miniconda3/bin/conda" "shell.$shell" 'hook' 2>/dev/null)"
	if [ $? -eq 0 ]; then
		eval "$__conda_setup"
	else
		if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
			. "$HOME/miniconda3/etc/profile.d/conda.sh"
		else
			export PATH="/home/derek/miniconda3/bin:$PATH"
		fi
	fi
	unset __conda_setup
fi

# direnv
(command -v direnv >/dev/null 2>&1) && eval "$(direnv hook "$shell")"

# dropbox
if command -v dropbox.py >/dev/null 2>&1; then
	alias cddb='cd /data/dropbox'
	dropbox.py autostart yes
	dropbox.py start >/dev/null 2>&1
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
if [ -f "$XDG_CONFIG_HOME/fzf/fzf.$shell" ]; then
	source "$XDG_CONFIG_HOME/fzf/fzf.$shell"
	if (command -v bat >/dev/null 2>&1) &&
		(command -v fd >/dev/null 2>&1) &&
		(command -v tree >/dev/null 2>&1); then
		_fzf_ctrl_t_alt_c_command='fd -HL -c=always -E=.git'
		_fzf_ctrl_t_alt_c_opts="
      --ansi
      --bind='ctrl-u:preview-page-up'
      --bind='ctrl-d:preview-page-down'
      --preview '([[ -d {} ]] && tree -C {}) || ([[ -f {} ]] && bat --style=full --color=always {}) || echo {}'
      --preview-window 'right:60%:wrap'"
		export FZF_CTRL_T_COMMAND="$_fzf_ctrl_t_alt_c_command -t=f -t=d"
		export FZF_CTRL_T_OPTS="$_fzf_ctrl_t_alt_c_opts"
		export FZF_CTRL_R_OPTS='--ansi'
		export FZF_ALT_C_COMMAND="$_fzf_ctrl_t_alt_c_command -t=d"
		export FZF_ALT_C_OPTS="$_fzf_ctrl_t_alt_c_opts"
	fi
fi

# git
alias cdr='cd $(git root)'
alias gitconfig='$EDITOR $XDG_CONFIG_HOME/.cache/git/config'
alias gitignore='$EDITOR $XDG_CONFIG_HOME/.cache/git/ignore'
for al in $(git --list-cmds=alias); do
	alias "g$al"="git $al"
done

# gitweb
(command -v gitweb >/dev/null 2>&1) && alias gw='gitweb'

# googler
(command -v googler >/dev/null 2>&1) && alias g='googler'

# npm
(command -v npm >/dev/null 2>&1) && source <(npm completion)

# nvim
if command -v nvim >/dev/null 2>&1; then
	alias n='nvim'
	alias v='nvim'
	alias vim='nvim'
	alias vimrc='$EDITOR $XDG_CONFIG_HOME/nvim/init.vim'
	export EDITOR=nvim
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

# python: flask
if command -v python >/dev/null 2>&1; then
	export FLASK_DEBUG=1
fi

# python: numpy
if command -v python >/dev/null 2>&1; then
	export MKL_NUM_THREADS=1
fi

# sh
alias shrc='$EDITOR ~/dotfiles/shell/rc.sh'

# starship
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init "$shell")"
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
	alias tmuxconf='$EDITOR ~/.tmux.conf.local'
fi

# xclip
if command -v xclip >/dev/null 2>&1; then
	alias pbcopy='xclip -selection clipboard'
	alias pbpaste='xclip -selection clipboard -o'
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
	export _ZO_EXCLUDE_DIRS="/tmp"
	eval "$(zoxide init "$shell" --cmd=c)"
fi

# zsh
alias zshrc='$EDITOR $HOME/.zshrc'

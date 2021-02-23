#!/usr/bin/env bash

# shellcheck disable=SC1091,SC2139,SC2140,SC2181
# shellcheck source=/dev/null

__shell="$1"

# === system ==
# XDG
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$USER}"

# dotfiles
export PATH_DOTFILES="${PATH_DOTFILES:-$HOME/dotfiles}"
__config_local="$XDG_CONFIG_HOME/shell/config.local.sh"
if [ -f "$__config_local" ]; then
	source "$__config_local" zsh
fi

# homebrew
export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin${PATH:+:$PATH}"
__share="$HOMEBREW_PREFIX/share"
export MANPATH="$__share/man${MANPATH:+:$MANPATH}:"
export INFOPATH="$__share/info${INFOPATH:+:$INFOPATH}"
__brew_dir=/home/linuxbrew_dir/.linuxbrew_dir/bin/brew_dir
if [ -f "$__brew_dir" ]; then
	eval "$("$__brew_dir" shellenv)"
fi

# === applications ===
# atom
if command -v atom >/dev/null 2>&1; then
	export GIST_ID=690a59ef26208e43fa880c874e01c1
fi

# bash
if command -v bash >/dev/null 2>&1; then
	alias bashrc='$EDITOR $HOME/.bashrc'
fi

# bat
if command -v bat >/dev/null 2>&1; then
	alias cat='bat'
	alias catp='bat --style=plain'
	tf() { tail -f "$1" | bat --paging=never -l log; }
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# batgrep
if command -v batgrep >/dev/null 2>&1; then
	alias bg='batgrep'
fi

# bin
while IFS= read -d '' -r __bin; do
	export PATH="$__bin${PATH:+:$PATH}"
done < <(find "$PATH_DOTFILES" -name bin -print0 -type d)

# cargo
__cargo_bin="$HOME/.cargo/bin"
if [ -d "$__cargo_bin" ]; then
	export PATH="$__cargo_bin${PATH:+:$PATH}"
fi

# cd
alias ~='cd $HOME'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias cddf='cd $PATH_DOTFILES'
alias cddl='cd $HOME/Downloads'
alias cddt='cd $HOME/Desktop'
alias cdp='cd $HOME/Pictures'
alias cdw='cd $HOME/work'
mkdir -p "$HOME/work"

# conda
__miniconda3="$HOME/miniconda3"
if [ -d "$__miniconda3" ]; then
	__conda_bin="$__miniconda3/bin"
	__conda_setup="$("$__conda_bin/conda" "shell.$__shell" 'hook' 2>/dev/null)"
	if [ $? -eq 0 ]; then
		eval "$__conda_setup"
	else
		__conda_sh="$__miniconda3/etc/profile.d/conda.sh"
		if [ -f "$__conda_sh" ]; then
			. "$__conda_sh"
		else
			export PATH="$__conda_bin${PATH:+:$PATH}"
		fi
	fi
	unset __conda_setup
	alias cec='conda env create --force'
	alias cel='conda env list'
	alias ceu='conda env update'
	export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
	eval "$(direnv hook "$__shell")"
	alias dea='direnv allow'
fi

# dropbox
__data_dir=/data/derek
if [ -d "$__data_dir" ] && (command -v dropbox.py >/dev/null 2>&1); then
	HOME="$__data_dir" dropbox.py start >/dev/null 2>&1
	__path_dropbox="$__data_dir/Dropbox"
	if [ -d "$__path_dropbox" ]; then
		alias cddb='cd $PATH_DROPBOX'
		export PATH_DROPBOX="$__path_dropbox"
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
	__exa_base() { exa -F --group-directories-first "$@"; }
	__exa_short() { __exa_base -x "$@"; }
	l() { __exa_short --git-ignore "$@"; }
	la() { l -a "$@"; }
	lag() { __exa_short -a "$@"; }
	__exa_long() { __exa_base -ghl --git --time-style=long-iso "$@"; }
	ll() { __exa_long --git-ignore "$@"; }
	lla() { ll -a "$@"; }
	llag() { __exa_long -a "$@"; }
fi

# fzf
__fzf_shell="$XDG_CONFIG_HOME/fzf/fzf.$__shell"
if [ -f "$__fzf_shell" ]; then
	source "$__fzf_shell"
	if (command -v bat >/dev/null 2>&1) && (command -v fd >/dev/null 2>&1) &&
		(command -v tree >/dev/null 2>&1); then
		# https://bit.ly/2OMLMpm
		export FZF_DEFAULT_COMMAND='fd -HL -c=always -E=.git -E=node_modules'
		export FZF_DEFAULT_OPTS="
      --ansi
      --bind 'ctrl-a:select-all'
      --bind 'ctrl-e:execute(echo {+} | xargs -o vim)'
      --bind 'ctrl-v:execute(code {+})'
      --bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
      --color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'
      --height=80%
      --info=inline
      --layout=reverse
      --multi
      --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
      --preview-window 'right:60%:wrap'
      --prompt='∼ ' --pointer='▶' --marker='✓'
      "
		export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -t=f -t=d"
		export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND -t=d"
	fi
fi

# gem
if command -v gem >/dev/null 2>&1; then
	__bin="$(gem environment gemdir)/bin"
	if [ -d "$__bin" ]; then
		export PATH="$__bin${PATH:+:$PATH}"
	fi
fi

# git
if command -v git >/dev/null 2>&1; then
	alias cdr='cd $(git root)'
	alias gitconfig='$EDITOR $XDG_CONFIG_HOME/git/config'
	alias gitconfiglocal='$EDITOR $XDG_CONFIG_HOME/git/config.local'
	alias gitignore='$EDITOR $XDG_CONFIG_HOME/git/ignore'
	for al in $(git --list-cmds=alias); do
		alias "g$al"="git $al"
	done
fi

# git + gitweb
if (command -v git >/dev/null 2>&1) && (command -v gitweb >/dev/null 2>&1); then
	alias gpw='git push && gitweb'
fi

# gitweb
if command -v gitweb >/dev/null 2>&1; then
	alias gw='gitweb'
fi

# googler
if command -v googler >/dev/null 2>&1; then
	alias g='googler'
fi

# less
if command -v less >/dev/null 2>&1; then
	__less="$XDG_CACHE_HOME/less"
	mkdir -p "$__less"
	export LESSHISTFILE="$__less/history"
	export LESSKEY="$__less/lesskey"
fi

# nano
if command -v nano >/dev/null 2>&1; then
	alias nanorc='$EDITOR $XDG_CONFIG_HOME/nano/nanorc'
fi

# npm
if command -v npm >/dev/null 2>&1; then
	alias npmrc='$EDITOR $HOME/.npmrc'
fi

# nvim
if command -v nvim >/dev/null 2>&1; then
	alias n='nvim'
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

# python
if command -v python >/dev/null 2>&1; then
	alias pie='pip install -e .'
	while IFS= read -d '' -r __pythonrc; do
		export PYTHONSTARTUP="$__pythonrc"
	done < <(find "$PATH_DOTFILES" -name pythonrc.py -print0 -type f)
fi

# python: flask
if command -v python >/dev/null 2>&1; then
	export FLASK_DEBUG=1
fi

# python: hypothesis
if command -v python >/dev/null 2>&1; then
	alias hypothesis-ci='export HYPOTHESIS_PROFILE=ci'
	alias hypothesis-debug='export HYPOTHESIS_PROFILE=debug'
	alias hypothesis-default='export HYPOTHESIS_PROFILE=default'
	alias hypothesis-dev='export HYPOTHESIS_PROFILE=dev'
fi

# python: numpy
if command -v python >/dev/null 2>&1; then
	export MKL_NUM_THREADS=1
fi

# python: tensorboard
if command -v python >/dev/null 2>&1; then
	alias tb='tensorboard --logdir .'
fi

# redis
if command -v redis >/dev/null 2>&1; then
	__redis="$XDG_CACHE_HOME/redis"
	mkdir -p "$__redis"
	export REDISCLI_HISTFILE="$__redis/history"
fi

# rg
if command -v rg >/dev/null 2>&1; then
	alias rg='rg -L --hidden --no-messages'
fi

# shell
alias shellconfig='$EDITOR $XDG_CONFIG_HOME/shell/config.sh'
alias shellconfiglocal='$EDITOR $XDG_CONFIG_HOME/shell/config.local.sh'

# starship
if command -v starship >/dev/null 2>&1; then
	alias starshiptoml='$EDITOR $XDG_CONFIG_HOME/starship.toml'
	eval "$(starship init "$__shell")"
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
	alias tmuxconf='$EDITOR $HOME/.tmux.conf.local'
fi

# ubuntu (https://askubuntu.com/a/492343)
if command -v apt >/dev/null 2>&1; then
	alias apt-installed="comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc " \
		"/var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"
fi

# vim
if command -v vim >/dev/null 2>&1; then
	alias v='vim'
	__init_vim="$XDG_CONFIG_HOME/nvim/init.vim"
	if [ -f "$__init_vim" ]; then
		export VIMINIT="source $__init_vim"
	fi
fi

# vim-superman
__bin="$HOME/.local/share/nvim/plugged/vim-superman/bin"
if [ -d "$__bin" ]; then
	export PATH="$__bin${PATH:+:$PATH}"
fi

# xclip
if command -v xclip >/dev/null 2>&1; then
	alias pbcopy='xclip -selection clipboard'
	alias pbpaste='xclip -selection clipboard -o'
fi

# watchexec + pre-commit
if (command -v watchexec >/dev/null 2>&1) &&
	(command -v pre-commit-current >/dev/null 2>&1); then
	alias wpcc='watchexec -d 5000 pre-commit-current'
fi

# wget
if command -v wget >/dev/null 2>&1; then
	export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
	export _ZO_EXCLUDE_DIRS="/tmp"
	export _ZO_RESOLVE_SYMLINKS=1
	eval "$(zoxide init "$__shell" --cmd=c)"
fi

# zsh
if command -v zsh >/dev/null 2>&1; then
	alias zshrc='$EDITOR $HOME/.zshrc'
fi

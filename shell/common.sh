#!/usr/bin/env sh
# shellcheck source=/dev/null

# bat
if command -v bat >/dev/null 2>&1; then
	cat() { bat "$@"; }
	catp() { bat --style=plain "$@"; }
	tf() { tail -f "$@" | bat --paging=never -l log; }
fi

# bottom
if command -v btm >/dev/null 2>&1; then
	htop() { btm "$@"; }
fi

# cd
alias ~='cd "${HOME}"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cdcache='cd "${HOME}"/.cache'
alias cdconfig='cd "${HOME}"/.config'
alias cdcache='cd "${XDG_CACHE_HOME:-${HOME}/.cache}"'
alias cdconfig='cd "${XDG_CONFIG_HOME:-${HOME}/.config}"'
alias cddb='cd "${HOME}"/Dropbox'
alias cddf='cd "${HOME}"/dotfiles'
alias cddl='cd "${HOME}"/Downloads'
alias cdw='cd "${HOME}"/work'

# chmod
chmod_files() { find . -type f -exec chmod "$1" {} \;; }
chmod_dirs() { find . -type d -exec chmod "$1" {} \;; }
chown_files() { find . -type f -exec chown "$1" {} \;; }
chown_dirs() { find . -type d -exec chown "$1" {} \;; }

# coverage
alias open-cov='open .coverage/html/index.html'

# direnv
if command -v direnv >/dev/null 2>&1; then
	alias dea='direnv allow'
fi

# eza
if command -v eza >/dev/null 2>&1; then
	__eza_base() { eza --classify=always --group-directories-first --ignore-glob=node_modules "$@"; }
	__eza_short() { __eza_base --across "$@"; }
	l() { __eza_short --git-ignore "$@"; }
	ls() { __eza_short --git-ignore "$@"; } # same as l
	la() { __eza_short --all "$@"; }
	__eza_long() { __eza_base --git --group --header --long --time-style=long-iso "$@"; }
	__eza_long_default() { __eza_long -a --git-ignore "$@"; }
	ll() { __eza_long --git-ignore "$@"; }
	lla() { __eza_long --all "$@"; }
	lal() { __eza_long --all "$@"; } #  same as lla

	if command -v watch >/dev/null 2>&1; then
		__watch_eza_base() {
			watch -d -n 0.1 --color -- \
				eza -aF --color=always --group-directories-first --ignore-glob=node_modules "$@"
		}
		__watch_eza_short() { __watch_eza_base -x "$@"; }
		alias wls='__watch_eza_short --git-ignore'
		alias wlsa='__watch_eza_short -a'
		__watch_eza_long() { __watch_eza_base -ghl --git --time-style=long-iso "$@"; }
		__watch_eza_long_default() { __watch_eza_long -a --git-ignore "$@"; }
		alias wl='__watch_eza_long_default'
		alias wll='__watch_eza_long_default'
		alias wla='__watch_eza_long -a'
	fi
fi

# fd
if command -v fd >/dev/null 2>&1; then
	fdd() { fd -Htd "$@"; }
	fde() { fd -Hte "$@"; }
	fdf() { fd -Htf "$@"; }
	fds() { fd -Hts "$@"; }
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
	export FZF_DEFAULT_COMMAND='fd -HL'
	export FZF_DEFAULT_OPTS="
    --height=80%
    --info=inline
    --layout=reverse
    --preview '([[ -f {} ]] && (bat -n --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
    "
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -tf -td"
	export FZF_CTRL_T_OPTS="
    --bind 'ctrl-a:select-all'
    --bind 'ctrl-d:deselect-all'
    --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'
    --header 'Ctrl-{a,d,y,/}'
    --multi
    --preview-window right:60%:wrap
    "
	export FZF_CTRL_R_OPTS="
    --preview-window up:3:wrap
    "
	export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND -td"
fi

# gh
if command -v gh >/dev/null 2>&1; then
	ghc() { gh pr create "$@"; }
	ghm() { gh pr merge --auto "$@"; }
	ghcm() { gh pr create && gh pr merge --auto "$@"; }
fi

# git
if command -v git >/dev/null 2>&1; then
	cdr() { cd "$(git rev-parse --show-toplevel)" || exit; }
fi
__file="${HOME}/dotfiles/git/aliases.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi

# hypothesis
hypothesis_ci() { export HYPOTHESIS_PROFILE=ci; }
hypothesis_debug() { export HYPOTHESIS_PROFILE=debug; }
hypothesis_default() { export HYPOTHESIS_PROFILE=default; }
hypothesis_dev() { export HYPOTHESIS_PROFILE=dev; }

# input
set bell-style none
set editing-mode vi

# neovim
if command -v nvim >/dev/null 2>&1; then
	alias n='nvim'
	alias cdplugins='cd "${XDG_CONFIG_HOME:-${HOME}/.config}/nvim/lua/custom/plugins"'
fi

# path
alias echo-path='sed '"'"'s/:/\n/g'"'"' <<< "${PATH}"'

# pip
alias pi='pip install'
alias pie='pip install --editable .'
alias piip='pip install ipython'
alias pijl='pip install jupyterlab jupyterlab-vim'
alias plo='pip list --outdated'
alias pui='pip uninstall'

# pre-commit
if command -v pre-commit >/dev/null 2>&1; then
	alias pca='pre-commit run -a'
	alias pcav='pre-commit run -av'
	alias pcau='pre-commit autoupdate'
	alias pci='pre-commit install'
fi

# ps
alias pst='ps -fLu "$USER"| wc -l'
if [ "$(command -v watch)" ]; then
	alias wpst='watch -d -n0.1 "ps -fLu \"$USER\" | wc -l"'
fi

# pytest
__file="${HOME}"/dotfiles/pytest/aliases.sh
if [ -f "$__file" ]; then
	. "$__file"
fi

# python
pyproject() { ${EDITOR} "$(groot)"/pyproject.toml; }

# rm
alias rmr='rm -r'
alias rmf='rm -f'
alias rmrf='rm -rf'

# ruff
if command -v ruff >/dev/null 2>&1; then
	alias rw='ruff check -w'
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
	if [ -z "$TMUX" ]; then
		tmux new-session -c "${PWD}"
	fi
	alias tmuxconf='$EDITOR "${HOME}"/.config/tmux/tmux.conf.local'
fi

# uv
if command -v uv >/dev/null 2>&1; then
	alias uvpi='uv pip install'
	alias uvpie='uv pip install --editable .'
	alias uvps='uv pip sync --strict requirements.txt'
fi

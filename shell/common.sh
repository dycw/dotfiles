#!/usr/bin/env sh
# shellcheck source=/dev/null

# bat
if command -v bat >/dev/null 2>&1; then
	alias cat='bat'
fi

# bottom
if command -v btm >/dev/null 2>&1; then
	alias htop='btm'
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

# coverage
alias open-cov='open .coverage/html/index.html'

# direnv
if command -v direnv >/dev/null 2>&1; then
	alias dea='direnv allow'
fi

# eza
if command -v eza >/dev/null 2>&1; then
	__eza_base() { eza -F --group-directories-first --ignore-glob=node_modules "$@"; }
	__eza_short() { __eza_base -x "$@"; }
	alias l='__eza_short --git-ignore'
	alias ls='__eza_short --git-ignore'
	alias lsa='__eza_short -a'
	__eza_long() { __eza_base -ghl --git --time-style=long-iso "$@"; }
	__eza_long_default() { __eza_long -a --git-ignore "$@"; }
	alias ll='__eza_long_default'
	alias la='__eza_long -a'

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
	alias fdd='fd -Htd'
	alias fde='fd -Hte'
	alias fdf='fd -Htf'
	alias fds='fd -Hts'
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
	alias ghc='gh pr create'
	alias ghm='gh pr merge --auto'
	alias ghcm='gh pr create && gh pr merge --auto'
fi

# git
__file="${HOME}/dotfiles/git/aliases.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi

# hypothesis
alias hypothesis-ci='export HYPOTHESIS_PROFILE=ci'
alias hypothesis-debug='export HYPOTHESIS_PROFILE=debug'
alias hypothesis-default='export HYPOTHESIS_PROFILE=default'
alias hypothesis-dev='export HYPOTHESIS_PROFILE=dev'

# input
set bell-style none
set editing-mode vi

# neovim 
if command -v nvim >/dev/null 2>&1; then
  alias n='nvim'
fi

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

# pytest
__file="${HOME}"/dotfiles/pytest/aliases.sh
if [ -f "$__file" ]; then
	. "$__file"
fi

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

#!/usr/bin/env sh
# shellcheck source=/dev/null

# bat
if command -v bat >/dev/null 2>&1; then
	cat() { bat "$@"; }
	catp() { bat --style=plain "$@"; }
	tf() { __tf_base "$1" --language=log; }
	tfp() { __tf_base "$1"; }
	__tf_base() {
		__file="$1"
		shift
		tail -F --lines=100 "$__file" | bat --paging=never --style=plain "$@"
	}
fi

# bottom
if command -v btm >/dev/null 2>&1; then
	htop() { btm "$@"; }
fi
bottom_toml() { ${EDITOR} "${HOME}/dotfiles/bottom/bottom.toml"; }

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

# cyberghost
if command -v cyberghostvpn >/dev/null 2>&1; then
	cyber_jp() { sudo cyberghostvpn --country-code JP --connect; }
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
	alias dea='direnv allow'
fi

# eza
if command -v eza >/dev/null 2>&1; then
	__eza_base() {
		eza --all --classify=always --group-directories-first "$@"
	}
	__eza_long() {
		__eza_base --git --group --header --long \
			--time-style=long-iso "$@"
	}
	l() { __eza_long --git-ignore "$@"; }
	la() { __eza_long "$@"; }
	__eza_short() { __eza_base --across "$@"; }
	ls() { __eza_short --git-ignore "$@"; }
	lsa() { __eza_short "$@"; }

	if command -v watch >/dev/null 2>&1; then
		__watch_eza_base() {
			watch -d -n 0.1 --color -- eza --all \
				--classify=always --color=always --git \
				--group --group-directories-first --header \
				--long --reverse --sort=modified \
				--time-style=long-iso "$@"
		}
		wl() { __watch_eza_base --git-ignore "$@"; }
		wla() { __watch_eza_base "$@"; }
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
	ghc() {
		unset __ghc_body
		if [ $# -eq 0 ]; then
			gh pr create -t="Created by ${USER}@$(hostname) at $(date +"%Y-%m-%d %H:%M:%S (%a)")" -b='.'
			return $?
		elif [ $# -eq 1 ]; then
			gh pr create -t="$1" -b='.'
			return $?
		elif [ $# -eq 2 ]; then
			if [ "$2" -eq "$2" ] 2>/dev/null; then
				__ghc_body="Closes #$2"
			else
				__ghc_body="$2"
			fi
			gh pr create -t="$1" -b="$__ghc_body"
			return $?
		else
			echo "'ghc' accepts [0..2] arguments"
			return 1
		fi
	}
	ghcm() {
		if [ $# -ge 1 ] && [ $# -le 2 ]; then
			ghc "$@" && ghm
			return $?
		else
			echo "'ghcm' accepts [1..2] arguments"
			return 1
		fi
	}
	ghic() {
		if [ $# -eq 1 ]; then
			gh issue create -t="$1" -b='.'
			return $?
		elif [ $# -eq 2 ]; then
			gh issue create -t="$1" -l="$2" -b='.'
			return $?
		elif [ $# -eq 3 ]; then
			gh issue create -t="$1" -l="$2" -b="$3"
			return $?
		else
			echo "'ghic' accepts [1..3] arguments"
			return 1
		fi
	}
	ghil() {
		if [ $# -eq 0 ]; then
			gh issue list
			return $?
		else
			echo "'ghil' accepts no arguments"
			return 1
		fi
	}
	# shellcheck disable=SC2120
	ghm() {
		if [ $# -eq 0 ]; then
			gh pr merge -s --auto
			return $?
		else
			echo "'ghm' accepts no arguments"
			return 1
		fi
	}
	ghv() {
		if [ $# -eq 0 ]; then
			gh pr view -w
			return $?
		else
			echo "'ghv' accepts no arguments"
			return 1
		fi
	}
fi

# git
if command -v git >/dev/null 2>&1; then
	cdr() { cd "$(git rev-parse --show-toplevel)" || exit; }
fi
__file="${HOME}/dotfiles/git/aliases.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi
gitignore() { ${EDITOR} "$(repo_root)/.gitignore"; }

# git + gh
if command -v git >/dev/null 2>&1 && command -v gh >/dev/null 2>&1; then
	gacc() {
		if [ $# -le 2 ]; then
			gac && ghc "$@"
			return $?
		else
			echo "'gacc' accepts [0..2] arguments"
			return 1
		fi
	}
	gaccmd() {
		if [ $# -ge 1 ] && [ $$ -le 2 ]; then
			gac && ghc "$@" && ghm && gcmd
			return $?
		else
			echo "'gaccmd' accepts [1..2] arguments"
			return 1
		fi
	}
fi

# hypothesis
hypothesis_ci() { export HYPOTHESIS_PROFILE='ci'; }
hypothesis_debug() { export HYPOTHESIS_PROFILE='debug'; }
hypothesis_default() { export HYPOTHESIS_PROFILE='default'; }
hypothesis_dev() {
	export HYPOTHESIS_PROFILE='dev'
	hypothesis_no_shrink
}
hypothesis_no_shrink() { export HYPOTHESIS_NO_SHRINK='1'; }

# input
set bell-style none
set editing-mode vi

# ipython
ipython_startup() { ${EDITOR} "${HOME}"/dotfiles/ipython/startup.py; }

# jupyter

# local
__file="${HOME}/common.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi

# marimo
mar() { uv run --with='beartype,hvplot,marimo[recommended],matplotlib,rich' marimo new; }
marimo_toml() { ${EDITOR} "${HOME}/dotfiles/marimo/marimo.toml"; }

# neovim
cdplugins() { cd "${XDG_CONFIG_HOME:-${HOME}/.config}/nvim/lua/custom/plugins" || exit; }
n() { nvim "$@"; }
lua_snippets() { ${EDITOR} "${HOME}/dotfiles/nvim/lua/snippets.lua"; }
plugins_dial() { ${EDITOR} "${HOME}/dotfiles/nvim/lua/plugins/dial.lua"; }

# pre-commit
if command -v pre-commit >/dev/null 2>&1; then
	alias pca='pre-commit run -a'
	alias pcav='pre-commit run -av'
	alias pcau='pre-commit autoupdate'
	alias pci='pre-commit install'
fi
pre_commit_config_yaml() { ${EDITOR} "$(repo_root)/.pre-commit-config.yaml"; }

# ps
alias pst='ps -fLu "$USER"| wc -l'
if command -v watch >/dev/null 2>&1; then
	alias wpst='watch -d -n0.1 "ps -fLu \"$USER\" | wc -l"'
fi

# pyright
if command -v pyright >/dev/null 2>&1; then
	pyr() { pyright "$@"; }
	pyrw() { pyr -w "$@"; }
fi

# pytest
__file="${HOME}/dotfiles/pytest/aliases.sh"
if [ -f "${__file}" ]; then
	. "${__file}"
fi

# python
pyproject() { ${EDITOR} "$(repo_root)/pyproject.toml"; }

# q
start_q() { QHOME="${HOME}"/q rlwrap -r "$HOME/q/m64/q" "$@"; }

# rg
if command -v pyright >/dev/null 2>&1 && command -v watchexec >/dev/null 2>&1; then
	rgw() { watchexec rg "$@"; }
fi

# rm
alias rmr='rm -r'
alias rmf='rm -f'
alias rmrf='rm -rf'

# ruff
if command -v ruff >/dev/null 2>&1; then
	rf() { pre-commit run run-ruff-format --all-files; }
	rcw() { ruff check -w "$@"; }
fi

# tailscale
if command -v tailscale >/dev/null 2>&1; then
	ts_status() { tailscale status; }
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
	if [ -z "$TMUX" ]; then
		tmux new-session -c "${PWD}"
	fi
fi
alias tmuxconf='${EDITOR} "${HOME}/.config/tmux/tmux.conf.local"'

# uv
if command -v uv >/dev/null 2>&1; then
	ip() {
		if [ $# -eq 0 ]; then
			uv run --with=ipython ipython
			return $?
		else
			echo "'ip' accepts no arguments"
			return 1
		fi
	}
	jl() {
		if [ $# -eq 0 ]; then
			uv run --with=altair,beartype,hvplot,jupyterlab,jupyterlab-code-formatter,jupyterlab-vim,matplotlib,rich,vegafusion,vegafusion-python-embed,vl-convert-python jupyter lab
			return $?
		else
			echo "'jl' accepts no arguments"
			return 1
		fi
	}
	uva() { uv add "$@"; }
	uvpi() { uv pip install "$@"; }
	uvpl() {
		if [ $# -eq 0 ]; then
			uv pip list
			return $?
		elif [ $# -eq 1 ]; then
			uv pip list | grep "$1"
			return $?
		else
			echo "'uvpl' accepts [0..1] arguments"
			return 1
		fi

	}
	uvplo() {
		if [ $# -eq 0 ]; then
			uv pip list --outdated
			return $?
		else
			echo "'uvplo' accepts no arguments"
			return 1
		fi
	}
	uvpu() { uv pip uninstall "$@"; }
	uvs() {
		if [ $# -eq 0 ]; then
			uv sync --upgrade
			return $?
		else
			echo "'uvs' accepts no arguments"
			return 1
		fi
	}
fi

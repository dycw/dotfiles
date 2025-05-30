#!/usr/bin/env sh
# shellcheck source=/dev/null
# shellcheck disable=SC2120

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
bottom_toml() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}/dotfiles/bottom/bottom.toml"
	else
		echo "'bottom_toml' accepts no arguments" || return 1
	fi
}

# cd
alias ~='cd "${HOME}"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
cdcache() {
	if [ $# -eq 0 ]; then
		cd "${XDG_CONFIG_HOME:-${HOME}}/.cache" || return $?
	else
		echo "'cdcache' accepts no arguments" || return 1
	fi
}
cdconfig() {
	if [ $# -eq 0 ]; then
		cd "${XDG_CONFIG_HOME:-${HOME}}/.config" || return $?
	else
		echo "'cdconfig' accepts no arguments" || return 1
	fi
}
cddb() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/Dropbox" || return $?
	else
		echo "'cddb' accepts no arguments" || return 1
	fi
}
cddbt() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/Dropbox/Temporary" || return $?
	else
		echo "'cddbt' accepts no arguments" || return 1
	fi
}
cddf() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/dotfiles" || return $?
	else
		echo "'cddl' accepts no arguments" || return 1
	fi
}
cddl() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/Downloads" || return $?
	else
		echo "'cddl' accepts no arguments" || return 1
	fi
}
cdh() {
	unset __cdh_pwd
	if [ $# -eq 0 ]; then
		__cdh_pwd="$(pwd)"
		cd .. || return $?
		cd "${__cdh_pwd}" || return $?
	else
		echo "'cdh' accepts no arguments" || return 1
	fi
}
cdw() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/work" || return $?
	else
		echo "'cdw' accepts no arguments" || return 1
	fi
}

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
	# shellcheck disable=SC2032
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

# git
if command -v git >/dev/null 2>&1; then
	cdr() {
		if [ $# -eq 0 ]; then
			cd "$(repo_root)" || return 1
		else
			echo "'cdr' accepts no arguments" || return 1
		fi
	}
fi
__file="${HOME}/dotfiles/git/aliases.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi
git_aliases() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}/dotfiles/git/aliases.sh"
	else
		echo "'git_aliases' accepts no arguments" || return 1
	fi
}
git_ignore() {
	if [ $# -eq 0 ]; then
		${EDITOR} "$(repo_root)/.gitignore"
	else
		echo "'git_ignore' accepts no arguments" || return 1
	fi
}

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
ipython_startup() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}/dotfiles/ipython/startup.py"
	else
		echo "'ipython_startup' accepts no arguments" || return 1
	fi
}

# jupyter

# local
__file="${HOME}/common.local.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi

# marimo
marimo_toml() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}/dotfiles/marimo/marimo.toml"
	else
		echo "'marimo_toml' accepts no arguments" || return 1
	fi
}

# neovim
cdplugins() {
	if [ $# -eq 0 ]; then
		cd "${XDG_CONFIG_HOME:-${HOME}/.config}/nvim/lua/custom/plugins" || return $?
	else
		echo "'cdplugins' accepts no arguments" || return 1
	fi
}
lua_snippets() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}/dotfiles/nvim/lua/snippets.lua"
	else
		echo "'lua_snippets' accepts no arguments" || return 1
	fi
}
plugins_dial() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}/dotfiles/nvim/lua/plugins/dial.lua"
	else
		echo "'plugins_dial' accepts no arguments" || return 1
	fi
}
if command -v nvim >/dev/null 2>&1; then
	n() { nvim "$@"; }
fi

# path
echo_path() {
	if [ $# -eq 0 ]; then
		echo "${PATH}" | tr ':' '\n' | nl || return 0
	else
		echo "'echo_path' accepts no arguments" || return 1
	fi
}

# pre-commit
if command -v pre-commit >/dev/null 2>&1; then
	alias pca='pre-commit run -a'
	alias pcav='pre-commit run -av'
	alias pcau='pre-commit autoupdate'
	alias pci='pre-commit install'
fi
pre_commit_config() {
	if [ $# -eq 0 ]; then
		${EDITOR} "$(repo_root)/.pre-commit-config.yaml"
	else
		echo "'pre_commit_config' accepts no arguments" || return 1
	fi
}

# ps
alias pst='ps -fLu "$USER"| wc -l'
if command -v watch >/dev/null 2>&1; then
	alias wpst='watch -d -n0.1 "ps -fLu \"$USER\" | wc -l"'
fi

# pytest
__file="${HOME}/dotfiles/pytest/aliases.sh"
if [ -f "${__file}" ]; then
	. "${__file}"
fi

# python
pyproject() {
	if [ $# -eq 0 ]; then
		${EDITOR} "$(repo_root)/pyproject.toml"
	else
		echo "'pyproject' accepts no arguments" || return 1
	fi
}

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

# shell
shell_common() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}/dotfiles/shell/common.sh"
	else
		echo "'shell_common' accepts no arguments" || return 1
	fi
}

# tailscale
if command -v tailscale >/dev/null 2>&1; then
	ts_status() { tailscale status; }
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
	tmux_attach() {
		unset __tmux_attach_window
		if [ $# -eq 0 ]; then
			__tmux_attach_window=0
		elif [ $# -eq 1 ]; then
			__tmux_attach_window="$1"
		else
			echo "'tmux_attach' accepts [0..1] arguments" || return 1
		fi
		tmux attach -t "${__tmux_attach_window}" || return $?
	}
	tmux_ls() {
		if [ $# -eq 0 ]; then
			# shellcheck disable=SC2033
			tmux ls || return $?
		else
			echo "'tmux_ls' accepts no arguments" || return 1
		fi
	}
	if [ -z "$TMUX" ]; then
		tmux new-session -c "${PWD}"
	fi
fi
tmux_conf_local() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}/.config/tmux/tmux.conf.local"
	else
		echo "'tmux_conf_local' accepts no arguments" || return 1
	fi
}

# uv
if command -v uv >/dev/null 2>&1; then
	ip() {
		if [ $# -eq 0 ]; then
			uv run --with=ipython ipython || return $?
		else
			echo "'ip' accepts no arguments" || return 1
		fi
	}
	jl() {
		if [ $# -eq 0 ]; then
			uv run --with=altair,beartype,hvplot,jupyterlab,jupyterlab-code-formatter,jupyterlab-vim,matplotlib,rich,vegafusion,vegafusion-python-embed,vl-convert-python jupyter lab || return $?
		else
			echo "'jl' accepts no arguments" || return 1
		fi
	}
	mar() {
		if [ $# -eq 0 ]; then
			uv run --with='beartype,hvplot,marimo[recommended],matplotlib,rich' marimo new
		else
			echo "'mar' accepts no arguments" || return 1
		fi
	}
	pyr() { uv run pyright "$@"; }
	pyrw() { uv run pyright -w "$@"; }
	uva() { uv add "$@"; }
	uvpi() { uv pip install "$@"; }
	uvpl() {
		if [ $# -eq 0 ]; then
			uv pip list || return $?
		elif [ $# -eq 1 ]; then
			(uv pip list | grep "$1") || return $?
		else
			echo "'uvpl' accepts [0..1] arguments" || return 1
		fi

	}
	uvplo() {
		if [ $# -eq 0 ]; then
			uv pip list --outdated || return $?
		else
			echo "'uvplo' accepts no arguments" || return 1
		fi
	}
	uvpu() { uv pip uninstall "$@"; }
	uvs() {
		if [ $# -eq 0 ]; then
			uv sync --upgrade || return $?
		else
			echo "'uvs' accepts no arguments" || return 1
		fi
	}
fi

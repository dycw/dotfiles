#!/usr/bin/env sh
# shellcheck source=/dev/null
# shellcheck disable=SC2120,SC2033

# ancestor
ancestor() {
	if [ $# -ne 2 ]; then
		echo_date "'ancestor' accepts 2 arguments" && return 1
	fi
	__type="$1"
	__name="$2"
	__dir="$(pwd)"
	while [ "${__dir}" != "/" ]; do
		__candidate="${__dir}"/"${__name}"
		case "${__type}" in
		file) if [ -f "${__candidate}" ]; then echo "${__dir}"; fi ;;
		directory) if [ -d "${__candidate}" ]; then echo "${__dir}"; fi ;;
		*) echo_date "'ancestor' accepts 'file' or 'directory' for the first argument; got ${__type}" && return 1 ;;
		esac
		__dir="$(dirname "${__dir}")"
	done
	echo_date "'ancestor' did not find an ancestor containing a ${__type} named '${__name}'" && return 1
}

ancestor_edit() {
	if [ $# -ne 1 ]; then
		echo_date "'ancestor_edit' accepts 1 arguments" && return 1
	fi
	__name="$1"
	__candidate=$(ancestor file "${__name}" 2>/dev/null)
	__code=$?
	if [ "${__code}" -ne 0 ]; then
		echo_date "'ancestor_edit' did not find an ancestor containing a file named '${__name}'" && return 1
	fi
	"${EDITOR}" "${__candidate}"/"${__name}"
}

# bat
if command -v bat >/dev/null 2>&1; then
	cat() { bat "$@"; }
	catp() { bat --style=plain "$@"; }
	tf() {
		if [ $# -ne 1 ]; then
			echo_date "'tf' accepts 1 argument" && return 1
		fi
		__tf_base "$1" --language=log
	}
	tfp() {
		if [ $# -ne 1 ]; then
			echo_date "'tfp' accepts 1 argument" && return 1
		fi
		__tf_base "$1"
	}
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
	if [ $# -ne 0 ]; then
		echo_date "'bottom_toml' accepts no arguments" && return 1
	fi
	${EDITOR} "${HOME}"/dotfiles/bottom/bottom.toml
}

# cd
alias ~='cd "${HOME}"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
cdcache() {
	if [ $# -ne 0 ]; then
		echo_date "'cdcache' accepts no arguments" && return 1
	fi
	cd "${XDG_CONFIG_HOME:-"${HOME}/.cache"}" || return $?
}
cdconfig() {
	if [ $# -ne 0 ]; then
		echo_date "'cdconfig' accepts no arguments" && return 1
	fi
	cd "${XDG_CONFIG_HOME:-"${HOME}/.config"}" || return $?
}
cddb() {
	if [ $# -ne 0 ]; then
		echo_date "'cddb' accepts no arguments" && return 1
	fi
	cd "${HOME}/Dropbox" || return $?
}
cddbt() {
	if [ $# -ne 0 ]; then
		echo_date "'cddbt' accepts no arguments" && return 1
	fi
	cd "${HOME}/Dropbox/Temporary" || return $?
}
cddf() {
	if [ $# -ne 0 ]; then
		echo_date "'cddl' accepts no arguments" && return 1
	fi
	cd "${HOME}/dotfiles" || return $?
}
cddl() {
	if [ $# -ne 0 ]; then
		echo_date "'cddl' accepts no arguments" && return 1
	fi
	cd "${HOME}/Downloads" || return $?
}
cd_here() {
	if [ $# -ne 0 ]; then
		echo_date "'cd_here' accepts no arguments" && return 1
	fi
	__pwd="$(pwd)"
	cd / || return $?
	cd "${__pwd}" || return $?
}
cdw() {
	if [ $# -ne 0 ]; then
		echo_date "'cdw' accepts no arguments" && return 1
	fi
	cd "${HOME}/work" || return $?
}

# chmod
chmod_files() {
	if [ $# -ne 1 ]; then
		echo_date "'chmod_files' accepts 1 argument" && return 1
	fi
	find . -type f -exec chmod "$1" {} \;
}
chmod_dirs() {
	if [ $# -ne 1 ]; then
		echo_date "'chmod_dirs' accepts 1 argument" && return 1
	fi
	find . -type d -exec chmod "$1" {} \;
}
chown_files() {
	if [ $# -ne 1 ]; then
		echo_date "'chown_files' accepts 1 argument" && return 1
	fi
	find . -type f -exec chown "$1" {} \;
}
chown_dirs() {
	if [ $# -ne 1 ]; then
		echo_date "'chown_dirs' accepts 1 argument" && return 1
	fi
	find . -type d -exec chown "$1" {} \;
}

# coverage
alias open-cov='open .coverage/html/index.html'

# debug
set_debug() {
	if [ $# -ne 0 ]; then
		echo_date "'set_debug' accepts no arguments" && return 1
	fi
	export DEBUG='1'
}
clear_debug() {
	if [ $# -ne 0 ]; then
		echo_date "'clear_debug' accepts no arguments" && return 1
	fi
	unset DEBUG
}

# direnv
if command -v direnv >/dev/null 2>&1; then
	dea() {
		if [ $# -ne 0 ]; then
			echo_date "'dea' accepts no arguments" && return 1
		fi
		direnv allow
	}
fi

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# eza
if command -v eza >/dev/null 2>&1; then
	__eza_base() {
		eza --all --classify=always --group-directories-first "$@"
	}
	__eza_long() {
		__eza_base --git --group --header --long --time-style=long-iso "$@"
	}
	l() { __eza_long --git-ignore "$@"; }
	la() { __eza_long "$@"; }
	__eza_short() { __eza_base --across "$@"; }
	# shellcheck disable=SC2032
	ls() { __eza_short --git-ignore "$@"; }
	lsa() { __eza_short "$@"; }

	if command -v watch >/dev/null 2>&1; then
		__watch_eza_base() {
			watch --color --differences --interval=0.5 -- \
				eza --all --classify=always --color=always --git --group \
				--group-directories-first --header --long --reverse \
				--sort=modified --time-style=long-iso "$@"
		}
		wl() { __watch_eza_base --git-ignore "$@"; }
		wla() { __watch_eza_base "$@"; }
	fi
fi

# fd
if command -v fd >/dev/null 2>&1; then
	fdd() { __fd_base 'directory' "$@"; }
	fde() { __fd_base 'empty' "$@"; }
	fdf() { __fd_base 'file' "$@"; }
	fds() { __fd_base 'symlink' "$@"; }
	__fd_base() {
		if [ $# -le 0 ]; then
			echo_date "'__fd_base' accepts [1,..] arguments" && return 1
		fi
		__type=$1
		shift
		fd --hidden --type="$__type" "$@"
	}
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
	export FZF_DEFAULT_COMMAND='fd -HL --exclude .git'
	export FZF_DEFAULT_OPTS="
    --height=80%
    --info=inline
    --layout=reverse
    --preview '([[ -f {} ]] && (bat -n --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
    "
	export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND} -tf -td"
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
	export FZF_ALT_C_COMMAND="${FZF_DEFAULT_COMMAND} -td"
fi

# git
if command -v git >/dev/null 2>&1; then
	cdr() {
		if [ $# -ne 0 ]; then
			echo_date "'cdr' accepts no arguments" && return 1
		fi
		cd "$(repo_root)" || return $?
	}
fi
__file="${HOME}/dotfiles/git/aliases.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi
git_aliases() {
	if [ $# -ne 0 ]; then
		echo_date "'git_aliases' accepts no arguments" && return 1
	fi
	${EDITOR} "${HOME}"/dotfiles/git/aliases.sh
}
git_ignore() {
	if [ $# -ne 0 ]; then
		echo_date "'git_ignore' accepts no arguments" && return 1
	fi
	${EDITOR} "$(repo_root)"/.gitignore
}

# hypothesis
hypothesis_ci() {
	if [ $# -ne 0 ]; then
		echo_date "'hypothesis_ci' accepts no arguments" && return 1
	fi
	export HYPOTHESIS_PROFILE='ci'
}
hypothesis_debug() {
	if [ $# -ne 0 ]; then
		echo_date "'hypothesis_debug' accepts no arguments" && return 1
	fi
	export HYPOTHESIS_PROFILE='debug'
}
hypothesis_default() {
	if [ $# -ne 0 ]; then
		echo_date "'hypothesis_default' accepts no arguments" && return 1
	fi
	export HYPOTHESIS_PROFILE='default'
}
hypothesis_dev() {
	if [ $# -ne 0 ]; then
		echo_date "'hypothesis_dev' accepts no arguments" && return 1
	fi
	export HYPOTHESIS_PROFILE='dev'
	hypothesis_no_shrink
}
hypothesis_no_shrink() {
	if [ $# -ne 0 ]; then
		echo_date "'hypothesis_no_shrink' accepts no arguments" && return 1
	fi
	export HYPOTHESIS_NO_SHRINK='1'
}

# input
set bell-style none
set editing-mode vi

# ipython
ipython_startup() {
	if [ $# -ne 0 ]; then
		echo_date "'ipython_startup' accepts no arguments" && return 1
	fi
	${EDITOR} "${HOME}"/dotfiles/ipython/startup.py
}

# local
__file="${HOME}/common.local.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi

# marimo
marimo_toml() {
	if [ $# -ne 0 ]; then
		echo_date "'marimo_toml' accepts no arguments" && return 1
	fi
	${EDITOR} "${HOME}"/dotfiles/marimo/marimo.toml
}

# neovim
cdplugins() {
	if [ $# -ne 0 ]; then
		echo_date "'cdplugins' accepts no arguments" && return 1
	fi
	cd "${XDG_CONFIG_HOME:-"${HOME}/.config"}/nvim/lua/plugins" || return $?
}
lua_snippets() {
	if [ $# -ne 0 ]; then
		echo_date "'lua_snippets' accepts no arguments" && return 1
	fi
	${EDITOR} "${HOME}"/dotfiles/nvim/lua/snippets.lua
}
plugins_dial() {
	if [ $# -ne 0 ]; then
		echo_date "'plugins_dial' accepts no arguments" && return 1
	fi
	${EDITOR} "${HOME}"/dotfiles/nvim/lua/plugins/dial.lua
}
if command -v nvim >/dev/null 2>&1; then
	n() { nvim "$@"; }
fi

# path
echo_path() {
	if [ $# -ne 0 ]; then
		echo_date "'echo_path' accepts no arguments" && return 1
	fi
	echo_date "\$PATH:"
	echo "${PATH}" | tr ':' '\n' | nl
}

# pre-commit
if command -v pre-commit >/dev/null 2>&1; then
	pca() {
		if [ $# -ne 0 ]; then
			echo_date "'pca' accepts no arguments" && return 1
		fi
		pre-commit run --all-files
	}
	pcav() {
		if [ $# -ne 0 ]; then
			echo_date "'pcav' accepts no arguments" && return 1
		fi
		pre-commit run --all-files --verbose
	}
	pcau() {

		if [ $# -ne 0 ]; then
			echo_date "'pcau' accepts no arguments" && return 1
		fi
		pre-commit autoupdate
	}
	pci() {
		if [ $# -ne 0 ]; then
			echo_date "'pci' accepts no arguments" && return 1
		fi
		pre-commit install
	}
fi
pre_commit_config() {
	if [ $# -ne 0 ]; then
		echo_date "'pre_commit_config' accepts no arguments" && return 1
	fi
	ancestor_edit .pre-commit-config.yaml
}

# ps + pgrep
pgrepf() {
	if [ $# -ne 1 ]; then
		echo_date "'pgrepf' accepts 1 argument" && return 1
	fi
	__pids=$(pgrep -f "$1" | tr '\n' ' ')
	if [ -z "${__pids}" ]; then
		echo_date "No process matched: $1" && return 1
	fi
	# shellcheck disable=SC2046
	ps -fp "${__pids}"
}
if command -v fzf >/dev/null 2>&1; then
	pgrep_kill() {
		if [ $# -ne 1 ]; then
			echo_date "'pgrep_kill' accepts 1 argument" && return 1
		fi
		__pattern=$1
		__pids=$(pgrep -f "$__pattern" | tr '\n' ' ')
		if [ -z "$__pids" ]; then
			echo_date "No process matched '$__pattern'" && return 0
		fi
		__results=$(ps -fp "$__pids")
		__selected=$(
			printf '%s\n' "$__results" |
				awk 'NR>1' |
				fzf --multi \
					--header-lines=0 \
					--prompt="Kill which $__pattern process? " \
					--preview="printf '%s\n' \"$__results\" | head -1; echo {}; " \
					--preview-window=up:3:wrap
		)
		if [ -z "$__selected" ]; then
			echo_date "No process selected" && return 0
		fi
		# shellcheck disable=SC2046
		set -- $(printf '%s\n' "$__selected" | awk '{print $2}')
		echo_date "Killing PIDs: $*"
		kill -9 "$@"
	}
fi
if command -v watch >/dev/null 2>&1; then
	wpgrepf() {
		if [ $# -ne 0 ]; then
			echo_date "'wpgrepf' accepts 1 argument" && return 1
		fi
		watch --color --differences --interval=0.5 -- \
			"pids=\$(pgrep -f \"$1\"); if [ -n \"\${pids}\" ]; then ps -fp \${pids}; else echo \"No process matched: $1\"; fi"
	}
fi

# pyright
pyr() { pyright "$@"; }
pyrw() { pyright -w "$@"; }

# pyright + pytest
pyrt() { pyright "$@" && pytest "$@"; }

# pytest
__file="${HOME}/dotfiles/pytest/aliases.sh"
if [ -f "${__file}" ]; then
	. "${__file}"
fi

# python
pyproject() {
	if [ $# -ne 0 ]; then
		echo_date "'pyproject' accepts no arguments" && return 1
	fi
	ancestor_edit pyproject.toml
}

# q
start_q() { QHOME="${HOME}"/q rlwrap -r "$HOME/q/m64/q" "$@"; }

# rg
if command -v rg >/dev/null 2>&1; then
	env_rg() {
		if [ $# -ne 1 ]; then
			echo_date "'env_rg' accepts 1 argument" && return 1
		fi
		env | rg "$1"
	}
	if command -v watch >/dev/null 2>&1; then
		wrg() { watch --color --differences --interval=0.5 -- rg "$@"; }
	fi

fi

# rm
rmr() { rm -r "$@"; }
rmf() { rm -f "$@"; }
rmrf() { rm -rf "$@"; }

# ruff
if command -v ruff >/dev/null 2>&1; then
	rcw() { ruff check -w "$@"; }
fi

# secrets
secrets_toml() {
	if [ $# -ne 0 ]; then
		echo_date "'secrets_toml' accepts no arguments" && return 1
	fi
	ancestor_edit secrets.toml
}

# settings
settings_toml() {
	if [ $# -ne 0 ]; then
		echo_date "'settings_toml' accepts no arguments" && return 1
	fi
	ancestor_edit settings.toml
}

# shell
shell_common() {
	if [ $# -ne 0 ]; then
		echo_date "'shell_common' accepts no arguments" && return 1
	fi
	${EDITOR} "${HOME}"/dotfiles/shell/common.sh
}

# SSH
ssh_home() {
	if [ $# -ne 0 ]; then
		echo_date "'ssh_home' accepts no arguments" && return 1
	elif [ -z "${SSH_HOME_USER}" ]; then
		echo_date "'\$SSH_HOME_USER' does not exist" && return 1
	elif [ -z "${SSH_HOME_HOST}" ]; then
		echo_date "'\$SSH_HOME_HOST' does not exist" && return 1
	fi
	ssh "${SSH_HOME_USER}@${SSH_HOME_HOST}"
}
ssh_tunnel_home() {
	if [ $# -ne 0 ]; then
		echo_date "'ssh_tunnel_home' accepts no arguments" && return 1
	elif [ -z "${SSH_HOME_USER}" ]; then
		echo_date "'\$SSH_HOME_USER' does not exist" && return 1
	elif [ -z "${SSH_HOME_HOST}" ]; then
		echo_date "'\$SSH_HOME_HOST' does not exist" && return 1
	elif [ -z "${SSH_TUNNEL_HOME_PORT}" ]; then
		echo_date "'\$SSH_TUNNEL_HOME_PORT' does not exist" && return 1
	fi
	ssh -N -L "${SSH_TUNNEL_HOME_PORT}:localhost:${SSH_TUNNEL_HOME_PORT}" \
		"${SSH_HOME_USER}@${SSH_HOME_HOST}"
}

# tailscale
if command -v tailscale >/dev/null 2>&1 && command -v tailscaled >/dev/null 2>&1; then
	ts_up() {
		if [ $# -ne 0 ]; then
			echo_date "'ts_up' accepts no arguments" && return 1
		fi
		ts_down
		__file="${HOME}/tailscale.local.sh"
		if ! [ -f "${__file}" ]; then
			echo_date "'${__file}' does not exist" && return 1
		elif [ -z "${TAILSCALE_LOGIN_SERVER}" ]; then
			echo_date "'\$TAILSCALE_LOGIN_SERVER' does not exist" && return 1
		fi
		echo_date "Starting 'tailscaled' in the background..."
		sudo tailscaled &
		echo_date "Starting 'tailscale'..."
		sudo tailscale up --accept-dns --accept-routes \
			--auth-key="file:${__file}" \
			--login-server="${TAILSCALE_LOGIN_SERVER}"
	}
	ts_down() {
		if [ $# -ne 0 ]; then
			echo_date "'ts_down' accepts no arguments" && return 1
		fi
		echo_date "Cleaning 'tailscaled'..."
		sudo tailscaled --cleanup
		echo_date "Killing 'tailscaled'..."
		sudo pkill tailscaled
		echo_date "Logging out of 'tailscale'..."
		sudo tailscale logout
	}
	ts_status() {
		if [ $# -ne 0 ]; then
			echo_date "'ts_status' accepts no arguments" && return 1
		fi
		tailscale status
	}
	if command -v jq >/dev/null 2>&1; then
		ts_ssh() {
			if [ $# -ne 0 ]; then
				echo_date "'ts_ssh' accepts no arguments" && return 1
			elif [ -z "${SSH_HOME_USER}" ]; then
				echo_date "'\$SSH_HOME_USER' does not exist" && return 1
			elif [ -z "${TAILSCALE_PEER_HOST_NAME}" ]; then
				echo_date "'\$TAILSCALE_PEER_HOST_NAME' does not exist" && return 1
			fi
			__host=$(tailscale status --json | jq -r --arg host "${TAILSCALE_PEER_HOST_NAME}" '.Peer[] | select(.HostName == $host) | .TailscaleIPs[0]')
			ssh "${SSH_HOME_USER}@${__host}"
		}
	fi
	if command -v watch >/dev/null 2>&1; then
		wts_status() {
			if [ $# -ne 0 ]; then
				echo_date "'wts_status' accepts no arguments" && return 1
			fi
			watch --color --differences --interval=0.5 -- tailscale status
		}
	fi
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
	tmux_attach() {
		if [ $# -eq 0 ]; then
			__window=0
		elif [ $# -eq 1 ]; then
			__window="$1"
		else
			echo_date "'tmux_attach' accepts [0..1] arguments" && return 1
		fi
		tmux attach -t "${__window}"
	}
	tmux_ls() {
		if [ $# -ne 0 ]; then
			echo_date "'tmux_ls' accepts no arguments" && return 1
		fi
		tmux ls
	}
	if [ -z "$TMUX" ]; then
		# not inside tmux
		if [ -z "${SSH_CONNECTION}" ]; then
			# not over SSH
			tmux new-session -c "${PWD}"
		elif [ -n "$SSH_CONNECTION" ]; then
			# is over SSH
			__count="$(tmux ls 2>/dev/null | wc -l)"
			if [ "${__count}" -eq 0 ]; then
				tmux new
			elif [ "${__count}" -eq 1 ]; then
				tmux attach -t "$(tmux ls | cut -d: -f1)"
			else
				echo_date "Multiple 'tmux' sessions detected:"
				tmux ls
			fi
		fi
	fi
fi
tmux_conf_local() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}"/.config/tmux/tmux.conf.local
	else
		echo_date "'tmux_conf_local' accepts no arguments" && return 1
	fi
}

# uv
if command -v uv >/dev/null 2>&1; then
	ipy() {
		if [ $# -eq 0 ]; then
			uv run --with=ipython --active --managed-python ipython || return $?
		else
			echo_date "'ipy' accepts no arguments" && return 1
		fi
	}
	jl() {
		if [ $# -eq 0 ]; then
			uv run --with=altair,beartype,hvplot,jupyterlab,jupyterlab-code-formatter,jupyterlab-vim,matplotlib,rich,vegafusion,vegafusion-python-embed,vl-convert-python --active --managed-python jupyter lab || return $?
		else
			echo_date "'jl' accepts no arguments" && return 1
		fi
	}
	mar() {
		if [ $# -eq 0 ]; then
			uv run --with='beartype,hvplot,marimo[recommended],matplotlib,rich' --active --managed-python marimo new
		else
			echo_date "'mar' accepts no arguments" && return 1
		fi
	}
	uva() { uv add --active --managed-python "$@"; }
	uvpi() { uv pip install --managed-python "$@"; }
	uvpl() {
		if [ $# -eq 0 ]; then
			uv pip list || return $?
		elif [ $# -eq 1 ]; then
			(uv pip list | grep "$1") || return $?
		else
			echo_date "'uvpl' accepts [0..1] arguments" && return 1
		fi

	}
	uvplo() {
		if [ $# -eq 0 ]; then
			uv pip list --outdated || return $?
		else
			echo_date "'uvplo' accepts no arguments" && return 1
		fi
	}
	uvpu() { uv pip uninstall "$@"; }
	uvr() { uv remove --active --managed-python "$@"; }
	uvs() {
		if [ $# -eq 0 ]; then
			uv sync --upgrade || return $?
		else
			echo_date "'uvs' accepts no arguments" && return 1
		fi
	}

	if command -v watch >/dev/null 2>&1; then
		wuvpi() { watch --color --differences --interval=0.5 -- uv pip install "$@"; }
	fi
fi

# venv
venv_recreate() {
	if [ $# -eq 0 ]; then
		__venv_recreate_candidate=$(ancestor file .envrc 2>/dev/null)
		__venv_recreate_code=$?
		if [ "${__venv_recreate_code}" -eq 0 ]; then
			__venv_recreate_venv="${__venv_recreate_candidate}"/.venv
			if [ -d "${__venv_recreate_venv}" ]; then
				rm -rf "${__venv_recreate_venv}" || return $?
			fi
			cd_here || return $?
		else
			echo_date "'venv_recreate' did not find an ancestor containg a file named '.envrc'" && return 1
		fi
	else
		echo_date "'venv_recreate' accepts no arguments" && return 1
	fi
}

# private

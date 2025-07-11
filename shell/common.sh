#!/usr/bin/env sh
# shellcheck source=/dev/null
# shellcheck disable=SC2120,SC2033

# ancestor
ancestor() {
	if [ $# -eq 2 ]; then
		__ancestor_type="$1"
		__ancestor_name="$2"
		__ancestor_dir="$(pwd)"
		while [ "${__ancestor_dir}" != "/" ]; do
			__ancestor_candidate="${__ancestor_dir}"/"${__ancestor_name}"
			case "${__ancestor_type}" in
			file)
				if [ -f "${__ancestor_candidate}" ]; then
					echo "${__ancestor_dir}" && return 0
				fi
				;;
			directory)
				if [ -d "${__ancestor_candidate}" ]; then
					echo "${__ancestor_dir}" && return 0
				fi
				;;
			*)
				echo_date "'ancestor' accepts 'file' or 'directory' for the first argument; got ${__ancestor_type}" && return 1
				;;
			esac
			__ancestor_dir="$(dirname "${__ancestor_dir}")"
		done
		echo_date "'ancestor' did not find an ancestor containing a ${__ancestor_type} named '${__ancestor_name}'" && return 1
	else
		echo_date "'ancestor' accepts 2 arguments" && return 1
	fi
}

ancestor_edit() {
	if [ $# -eq 1 ]; then
		__ancestor_edit_name="$1"
		__ancestor_edit_candidate=$(ancestor file "${__ancestor_edit_name}" 2>/dev/null)
		__ancestor_edit_code=$?
		if [ "${__ancestor_edit_code}" -eq 0 ]; then
			"${EDITOR}" "${__ancestor_edit_candidate}"/"${__ancestor_edit_name}" && return 0
		else
			echo_date "'ancestor_edit' did not find an ancestor containing a file named '${__ancestor_edit_name}'" && return 1
		fi
	else
		echo_date "'ancestor_edit' accepts 1 arguments" && return 1
	fi
}

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
		${EDITOR} "${HOME}"/dotfiles/bottom/bottom.toml
	else
		echo_date "'bottom_toml' accepts no arguments" && return 1
	fi
}

# cd
alias ~='cd "${HOME}"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
cdcache() {
	if [ $# -eq 0 ]; then
		cd "${XDG_CONFIG_HOME:-"${HOME}/.cache"}" || return $?
	else
		echo_date "'cdcache' accepts no arguments" && return 1
	fi
}
cdconfig() {
	if [ $# -eq 0 ]; then
		cd "${XDG_CONFIG_HOME:-"${HOME}/.config"}" || return $?
	else
		echo_date "'cdconfig' accepts no arguments" && return 1
	fi
}
cddb() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/Dropbox" || return $?
	else
		echo_date "'cddb' accepts no arguments" && return 1
	fi
}
cddbt() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/Dropbox/Temporary" || return $?
	else
		echo_date "'cddbt' accepts no arguments" && return 1
	fi
}
cddf() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/dotfiles" || return $?
	else
		echo_date "'cddl' accepts no arguments" && return 1
	fi
}
cddl() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/Downloads" || return $?
	else
		echo_date "'cddl' accepts no arguments" && return 1
	fi
}
cd_here() {
	if [ $# -eq 0 ]; then
		__cd_here_pwd="$(pwd)"
		cd / || return $?
		cd "${__cd_here_pwd}" || return $?
	else
		echo_date "'cd_here' accepts no arguments" && return 1
	fi
}
cdw() {
	if [ $# -eq 0 ]; then
		cd "${HOME}/work" || return $?
	else
		echo_date "'cdw' accepts no arguments" && return 1
	fi
}

# chmod
chmod_files() { find . -type f -exec chmod "$1" {} \;; }
chmod_dirs() { find . -type d -exec chmod "$1" {} \;; }
chown_files() { find . -type f -exec chown "$1" {} \;; }
chown_dirs() { find . -type d -exec chown "$1" {} \;; }

# coverage
alias open-cov='open .coverage/html/index.html'

# debug
set_debug() { export DEBUG='1'; }
clear_debug() { unset DEBUG; }

# direnv
if command -v direnv >/dev/null 2>&1; then
	alias dea='direnv allow'
fi

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

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
			watch --color --differences --interval=0.5 -- \
				eza --all --classify=always --color=always --git \
				--group --group-directories-first --header --long \
				--reverse --sort=modified --time-style=long-iso "$@"
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
		if [ $# -eq 0 ]; then
			cd "$(repo_root)" && return 1
		else
			echo_date "'cdr' accepts no arguments" && return 1
		fi
	}
fi
__file="${HOME}/dotfiles/git/aliases.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi
git_aliases() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}"/dotfiles/git/aliases.sh
	else
		echo_date "'git_aliases' accepts no arguments" && return 1
	fi
}
git_ignore() {
	if [ $# -eq 0 ]; then
		${EDITOR} "$(repo_root)"/.gitignore
	else
		echo_date "'git_ignore' accepts no arguments" && return 1
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
		${EDITOR} "${HOME}"/dotfiles/ipython/startup.py
	else
		echo_date "'ipython_startup' accepts no arguments" && return 1
	fi
}

# local
__file="${HOME}/common.local.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi

# marimo
marimo_toml() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}"/dotfiles/marimo/marimo.toml
	else
		echo_date "'marimo_toml' accepts no arguments" && return 1
	fi
}

# neovim
cdplugins() {
	if [ $# -eq 0 ]; then
		cd "${XDG_CONFIG_HOME:-"${HOME}/.config"}/nvim/lua/plugins" || return $?
	else
		echo_date "'cdplugins' accepts no arguments" && return 1
	fi
}
lua_snippets() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}"/dotfiles/nvim/lua/snippets.lua
	else
		echo_date "'lua_snippets' accepts no arguments" && return 1
	fi
}
plugins_dial() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}"/dotfiles/nvim/lua/plugins/dial.lua
	else
		echo_date "'plugins_dial' accepts no arguments" && return 1
	fi
}
if command -v nvim >/dev/null 2>&1; then
	n() { nvim "$@"; }
fi

# path
echo_path() {
	if [ $# -eq 0 ]; then
		echo_date "\$PATH:" || return 0
		echo "${PATH}" | tr ':' '\n' | nl || return 0
	else
		echo_date "'echo_path' accepts no arguments" && return 1
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
		ancestor_edit .pre-commit-config.yaml && return $?
	else
		echo_date "'pre_commit_config' accepts no arguments" && return 1
	fi
}

# ps + pgrep
pgrepf() {
	if [ $# -eq 1 ]; then
		__pids=$(pgrep -f "$1" | tr '\n' ' ')
		if [ -n "${__pids}" ]; then
			ps -fp "${__pids}" && return $?
		else
			echo_date "No process matched: $1" && return 1
		fi
	else
		echo_date "'pgrepf' accepts 1 argument" && return 1
	fi
}
if command -v fzf >/dev/null 2>&1; then
	pgrep_kill() {
		if [ $# -eq 1 ]; then
			__pattern=$1
			__pids=$(pgrep -f "$__pattern" | tr '\n' ' ')
			if [ -n "$__pids" ]; then
				__results=$(ps -fp "$__pids")
				__selected=$(printf '%s\n' "$__results" | awk 'NR>1' | fzf --multi \
					--header-lines=0 \
					--prompt="Kill which $__pattern process? " \
					--preview="printf '%s\n' \"$__results\" | head -1; echo {}; " \
					--preview-window=up:3:wrap)
				if [ -n "$__selected" ]; then
					# shellcheck disable=SC2046
					set -- $(printf '%s\n' "$__selected" | awk '{print $2}')
					echo_date "Killing PIDs: $*"
					kill -9 "$@"
				else
					echo_date "No process selected"
					return 0
				fi

			else
				echo_date "No process matched: $__pattern"
				return 1
			fi
		else
			echo_date "'pgrep_kill' accepts 1 argument" >&2
			return 1
		fi
	}
fi
if command -v watch >/dev/null 2>&1; then
	wps_pgrep() {
		if [ $# -eq 1 ]; then
			watch --color --differences --interval=0.5 -- "pids=\$(pgrep -f \"$1\"); if [ -n \"\${pids}\" ]; then ps -fp \${pids}; else echo \"No process matched: $1\"; fi"
		else
			echo_date "'wps_pgrep' accepts 1 argument" && return 1
		fi
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
	if [ $# -eq 0 ]; then
		ancestor_edit pyproject.toml
	else
		echo_date "'pyproject' accepts no arguments" && return 1
	fi
}

# q
start_q() { QHOME="${HOME}"/q rlwrap -r "$HOME/q/m64/q" "$@"; }

# rg
if command -v rg >/dev/null 2>&1; then
	env_rg() {
		if [ $# -eq 1 ]; then
			env | rg "$1" || return $?
		else
			echo_date "'env_rg' accepts 1 argument" && return 1
		fi
	}
	if command -v watch >/dev/null 2>&1; then
		wrg() { watch --color --differences --interval=0.5 -- rg "$@"; }
	fi

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

# secrets
secrets_toml() {
	if [ $# -eq 0 ]; then
		ancestor_edit secrets.toml
	else
		echo_date "'secrets_toml' accepts no arguments" && return 1
	fi
}

# settings
settings_toml() {
	if [ $# -eq 0 ]; then
		ancestor_edit settings.toml
	else
		echo_date "'settings_toml' accepts no arguments" && return 1
	fi
}

# shell
shell_common() {
	if [ $# -eq 0 ]; then
		${EDITOR} "${HOME}"/dotfiles/shell/common.sh
	else
		echo_date "'shell_common' accepts no arguments" && return 1
	fi
}

# SSH
ssh_home() {
	if [ $# -eq 0 ]; then
		if [ -z "${SSH_HOME_USER}" ]; then
			echo_date "'\$SSH_HOME_USER' does not exist" && return 1
		elif [ -z "${SSH_HOME_HOST}" ]; then
			echo_date "'\$SSH_HOME_HOST' does not exist" && return 1
		else
			ssh "${SSH_HOME_USER}@${SSH_HOME_HOST}" || return $?
		fi
	else
		echo_date "'ssh_home' accepts no arguments" && return 1
	fi
}
ssh_tunnel_home() {
	if [ $# -eq 0 ]; then
		if [ -z "${SSH_HOME_USER}" ]; then
			echo_date "'\$SSH_HOME_USER' does not exist" && return 1
		elif [ -z "${SSH_HOME_HOST}" ]; then
			echo_date "'\$SSH_HOME_HOST' does not exist" && return 1
		elif [ -z "${SSH_TUNNEL_HOME_PORT}" ]; then
			echo_date "'\$SSH_TUNNEL_HOME_PORT' does not exist" && return 1
		else
			ssh -N -L "${SSH_TUNNEL_HOME_PORT}:localhost:${SSH_TUNNEL_HOME_PORT}" "${SSH_HOME_USER}@${SSH_HOME_HOST}" || return $?
		fi
	else
		echo_date "'ssh_tunnel_home' accepts no arguments" && return 1
	fi
}

# tailscale
if command -v tailscale >/dev/null 2>&1 && command -v tailscaled >/dev/null 2>&1; then
	ts_up() {
		if [ $# -eq 0 ]; then
			ts_down || return $?
			__ts_up_auth_key="${HOME}/tailscale.local.sh"
			if ! [ -f "${__ts_up_auth_key}" ]; then
				echo_date "'${__ts_up_auth_key}' does not exist" && return 1
			fi
			if [ -z "${TAILSCALE_LOGIN_SERVER}" ]; then
				echo_date "'\$TAILSCALE_LOGIN_SERVER' does not exist" && return 1
			fi
			echo_date "Starting 'tailscaled' in the background..." || return $?
			sudo tailscaled &
			echo_date "Starting 'tailscale'..." || return $?
			sudo tailscale up --accept-dns --accept-routes --auth-key="file:${__ts_up_auth_key}" --login-server="${TAILSCALE_LOGIN_SERVER}" && return $?
		else
			echo_date "'ts_up' accepts no arguments" && return 1
		fi
	}
	ts_down() {
		if [ $# -eq 0 ]; then
			echo_date "Cleaning 'tailscaled'..." || return $?
			sudo tailscaled --cleanup
			echo_date "Killing 'tailscaled'..." || return $?
			sudo pkill tailscaled
			echo_date "Logging out of 'tailscale'..." || return $?
			sudo tailscale logout
			return 0
		else
			echo_date "'ts_down' accepts no arguments" && return 1
		fi
	}
	ts_status() {
		if [ $# -eq 0 ]; then
			tailscale status
		else
			echo_date "'ts_status' accepts no arguments" && return 1
		fi
	}
	if command -v jq >/dev/null 2>&1; then
		ts_ssh() {
			if [ $# -eq 0 ]; then
				if [ -z "${SSH_HOME_USER}" ]; then
					echo_date "'\$SSH_HOME_USER' does not exist" && return 1
				elif [ -z "${TAILSCALE_PEER_HOST_NAME}" ]; then
					echo_date "'\$TAILSCALE_PEER_HOST_NAME' does not exist" && return 1
				else
					__host_name=$(tailscale status --json | jq -r --arg hostname "${TAILSCALE_PEER_HOST_NAME}" '.Peer[] | select(.HostName == $hostname) | .TailscaleIPs[0]')
					ssh "${SSH_HOME_USER}@${__host_name}" || return $?
				fi
			else
				echo_date "'ts_ssh' accepts no arguments" && return 1
			fi
		}
	fi
	if command -v watch >/dev/null 2>&1; then
		wts_status() {
			if [ $# -eq 0 ]; then
				watch --color --differences --interval=0.5 -- tailscale status
			else
				echo_date "'wts_status' accepts no arguments" && return 1
			fi
		}
	fi
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
			echo_date "'tmux_attach' accepts [0..1] arguments" && return 1
		fi
		tmux attach -t "${__tmux_attach_window}" || return $?
	}
	tmux_ls() {
		if [ $# -eq 0 ]; then
			tmux ls || return $?
		else
			echo_date "'tmux_ls' accepts no arguments" && return 1
		fi
	}
	if [ -z "$TMUX" ]; then
		# not inside tmux
		if [ -z "${SSH_CONNECTION}" ]; then
			# not over SSH
			tmux new-session -c "${PWD}"
		elif [ -n "$SSH_CONNECTION" ]; then
			# is over SSH
			__tmux_session_count="$(tmux ls 2>/dev/null | wc -l)"
			if [ "${__tmux_session_count}" -eq 0 ]; then
				tmux new
			elif [ "${__tmux_session_count}" -eq 1 ]; then
				__tmux_session="$(tmux ls | cut -d: -f1)"
				tmux attach -t "${__tmux_session}"
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

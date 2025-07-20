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
		file)
			if [ -f "${__candidate}" ]; then
				echo "${__dir}" && return 0
			fi
			;;
		directory)
			if [ -d "${__candidate}" ]; then
				echo "${__dir}" && return 0
			fi
			;;
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
		if [ $# -ne 1 ]; then
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

# reboot/shutdown
reboot_now() {
	if [ $# -ne 0 ]; then
		echo_date "'reboot_now' accepts no arguments" && return 1
	fi
	__run_shutdown 'Reboot' 'r'
}
shutdown_now() {
	if [ $# -ne 0 ]; then
		echo_date "'shutdown_now' accepts no arguments" && return 1
	fi
	__run_shutdown 'Shut down' 'h'
}
__run_shutdown() {
	if [ $# -ne 2 ]; then
		echo_date "'__run_shutdown' accepts no arguments" && return 1
	fi
	__desc="$1"
	__flag="$2"
	printf "%s now? [Y/n] " "${__desc}"
	read -r __response
	__shutdown=$(printf "%s" "${__response}" | tr '[:upper:]' '[:lower:]')
	if [ -z "${__shutdown}" ] || [ "${__shutdown}" = "y" ] || [ "${__shutdown}" = "yes" ]; then
		sudo shutdown -"${__flag}" now
	else
		echo_date "%s cancelled" "${__desc}"
	fi
}

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
ts_ssh() {
	if [ $# -ne 0 ]; then
		echo_date "'ts_ssh' accepts no arguments" && return 1
	elif [ -z "${SSH_HOME_USER}" ]; then
		echo_date "'\$SSH_HOME_USER' does not exist" && return 1
	elif [ -z "${TAILSCALE_HOST_NAME}" ]; then
		echo_date "'\$TAILSCALE_HOST_NAME' does not exist" && return 1
	fi
	ssh "${SSH_HOME_USER}@${TAILSCALE_HOST_NAME}"
}
if command -v tailscale >/dev/null 2>&1 && command -v tailscaled >/dev/null 2>&1; then
	ts_status() {
		if [ $# -ne 0 ]; then
			echo_date "'ts_status' accepts no arguments" && return 1
		fi
		tailscale status
	}
	if command -v tailscaled >/dev/null 2>&1; then
		ts_up() {
			if [ $# -ne 0 ]; then
				echo_date "'ts_up' accepts no arguments" && return 1
			fi
			__file="${HOME}/tailscale-auth-key"
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
			__count="$(tmux ls 2>/dev/null | wc -l)"
			if [ "${__count}" -eq 0 ]; then
				tmux new
				return
			elif [ "${__count}" -eq 1 ]; then
				__session="$(tmux ls | cut -d: -f1)"
			else
				echo_date "ERROR: %d sessions found" "${__count}"
			fi
		elif [ $# -eq 1 ]; then
			__session="$1"
		else
			echo_date "'tmux_attach' accepts [0..1] arguments" && return 1
		fi
		tmux attach -t "${__session}"
	}
	tmux_detach() {
		if [ $# -ne 0 ]; then
			echo_date "'tmux_detach' accepts no arguments" && return 1
		fi
		tmux detach
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
	if [ $# -ne 0 ]; then
		echo_date "'tmux_conf_local' accepts no arguments" && return 1
	fi
	${EDITOR} "${HOME}"/.config/tmux/tmux.conf.local
}

# tsunami
if command -v tsunami >/dev/null 2>&1; then
	tsunami_get() {
		unset __host __all
		__rate="70M"
		__speedup="9/10"
		__slowdown="10/9"
		__blocksize="1200"
		__error="10%"

		usage() {
			cat <<EOF
Usage: $0 [options] host

Options:
  --rate=RATE
  --speedup=RATIO
  --slowdown=RATIO
  --blocksize=SIZE
  --error=PERCENT
  --all
EOF
			return 1
		}

		while [ $# -gt 0 ]; do
			case "$1" in
			--rate=*) __rate="${1#*=}" ;;
			--speedup=*) __speedup="${1#*=}" ;;
			--slowdown=*) __slowdown="${1#*=}" ;;
			--blocksize=*) __blocksize="${1#*=}" ;;
			--error=*) __error="${1#*=}" ;;
			--all) __all=1 ;;
			--help)
				usage
				return $?
				;;
			--*)
				echo_date "ERROR: Unknown option '$1'"
				usage
				return 1
				;;
			*) break ;;
			esac
			shift
		done

		if [ "$#" -ne 1 ]; then
			echo_date "ERROR: 'tsunami_get' accepts 1 positiona argment"
			usage
			return 1
		fi
		__host=$1
		shift

		# build command
		set -- connect "$__host" \
			set rate "$__rate" \
			set speedup "$__speedup" \
			set slowdown "$__slowdown" \
			set blocksize "$__blocksize" \
			set error "$__error"

		# select files
		if [ -n "${__all}" ]; then
			set -- "$@" get '*'
		else
			if ! command -v fzf >/dev/null 2>&1; then
				echo_date "ERROR: 'fzf' not found" && return 1
			fi

			__tmp_file=$(mktemp)
			trap 'rm -f "${__tmp_file}"' EXIT
			script -q "${__tmp_file}" tsunami connect "${__host}" dir quit
			__files=$(tr -d '\r' <"${__tmp_file}" | awk '
            /^[[:space:]]*[0-9]+\)/ {
                sub(/^[[:space:]]*[0-9]+\)[[:space:]]*/, "", $0)
                sub(/[[:space:]]+[0-9]+ bytes$/, "", $0)
                print $0
            }')
			__selected=$(printf '%s\n' "${__files}" | fzf -m)
			if [ -z "${__selected}" ]; then
				echo_date "ERROR: no files selected" && return 1
			fi
			while IFS= read -r __file; do
				set -- "$@" get "${__file}"
			done <<EOF
${__selected}
EOF
		fi

		# execute
		tsunami "$@" quit
	}
fi
if command -v tsunamid >/dev/null 2>&1; then
	tsunami_serve() {
		if [ $# -eq 0 ]; then
			__dir="${HOME}/work/tsunami/out"
		elif [ $# -eq 1 ]; then
			__dir="$1"
		else
			echo_date "'tsunami_serve' accepts 0 arguments" && return 1
		fi
		if ! [ -d "${__dir}" ]; then
			echo_date "ERROR: '${__dir}' does not exist" && return 1
		fi
		(
			cd "${__dir}" || exit 1
			# shellcheck disable=SC2035
			tsunamid *
		)
	}
fi

# uv
if command -v uv >/dev/null 2>&1; then
	ipy() {
		if [ $# -ne 0 ]; then
			echo_date "'ipy' accepts no arguments" && return 1
		fi
		uv run --with=ipython --active --managed-python ipython
	}
	jl() {
		if [ $# -ne 0 ]; then
			echo_date "'jl' accepts no arguments" && return 1
		fi
		uv run --with=altair \
			--with=beartype \
			--with=hvplot \
			--with=jupyterlab \
			--with=jupyterlab-code-formatter \
			--with=jupyterlab-vim \
			--with=matplotlib \
			--with=rich \
			--with=vegafusion \
			--with=vegafusion-python-embed \
			--with=vl-convert-python \
			--active --managed-python jupyter lab
	}
	mar() {
		if [ $# -ne 0 ]; then
			echo_date "'mar' accepts no arguments" && return 1
		fi
		uv run --with=beartype \
			--with=beartype \
			--with=hvplot \
			--with='marimo[recommended]' \
			--with=matplotlib \
			--with=rich \
			--active --managed-python marimo new
	}
	uva() { uv add --active --managed-python "$@"; }
	uvpi() { uv pip install --managed-python "$@"; }
	uvpl() {
		if [ $# -eq 0 ]; then
			uv pip list
		elif [ $# -eq 1 ]; then
			(uv pip list | grep "$1")
		else
			echo_date "'uvpl' accepts [0..1] arguments" && return 1
		fi
	}
	uvplo() {
		if [ $# -ne 0 ]; then
			echo_date "'uvplo' accepts no arguments" && return 1
		fi
		uv pip list --outdated
	}
	uvpu() { uv pip uninstall "$@"; }
	uvr() { uv remove --active --managed-python "$@"; }
	uvs() {
		if [ $# -ne 0 ]; then
			echo_date "'uvs' accepts no arguments" && return 1
		fi
		uv sync --upgrade
	}
	if command -v watch >/dev/null 2>&1; then
		wuvpi() { watch --color --differences --interval=0.5 -- uv pip install "$@"; }
	fi
fi

# venv
venv_recreate() {
	if [ $# -ne 0 ]; then
		echo_date "'venv_recreate' accepts no arguments" && return 1
	fi
	__candidate=$(ancestor file .envrc 2>/dev/null)
	__code=$?
	if [ "${__code}" -ne 0 ]; then
		echo_date "'venv_recreate' did not find an ancestor containg a file named '.envrc'" && return 1
	fi
	__venv="${__candidate}"/.venv
	if [ -d "${__venv}" ]; then
		rm -rf "${__venv}"
	fi
	cd_here
}

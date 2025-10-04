#!/usr/bin/env sh
# shellcheck source=/dev/null
# shellcheck disable=SC2120,SC2033

# age
if command -v age >/dev/null 2>&1; then
	encrypt() {
		[ $# -le 1 ] || [ $# -ge 4 ] && echo_date "'encrypt' accepts [2..3] arguments; got $#" && return 1
		if [ -f "$1" ]; then
			__encrypt_mode='file'
		elif [ "${1#age}" != "$1" ]; then
			__encrypt_mode='key'
		else
			echo_date "'$1' is neither a file nor a public key" && return 1
		fi
		! [ -f "$2" ] && echo_date "'$2' does not exist" && return 1
		if [ $# -eq 3 ]; then
			__encrypt_output="$3"
		else
			__encrypt_output="$2.enc"
		fi
		if [ "${__encrypt_mode}" = 'file' ]; then
			age --encrypt --recipients-file="$1" --output="${__encrypt_output}" "$2"
		elif [ "${__encrypt_mode}" = 'key' ]; then
			age --encrypt --recipient="$1" --output="${__encrypt_output}" "$2"
		else
			echo_date "'encrypt' impossible case; got '${__encrypt_mode}'" && return 1
		fi
	}
	decrypt() {
		[ $# -le 1 ] || [ $# -ge 4 ] && echo_date "'decrypt' accepts [2..3] arguments; got $#" && return 1
		! [ -f "$1" ] && echo_date "'$1' does not exist" && return 1
		! [ -f "$2" ] && echo_date "'$2' does not exist" && return 1
		if [ $# -eq 3 ]; then
			__decrypt_output="$3"
		elif [ "${2%.enc}" = "$2" ]; then
			echo hi
			__decrypt_output="$2.dec"
		else
			echo bye
			__decrypt_output="${2%.enc}"
			echo "${__decrypt_output}"
		fi
		age --decrypt --identity="$1" --output="${__decrypt_output}" "$2"
	}
fi

# aichat
if command -v aichat >/dev/null 2>&1; then
	a() {
		if [ $# -eq 0 ]; then
			aichat
		else
			aichat "$*"
		fi
	}
	ac() {
		if [ $# -eq 0 ]; then
			aichat --role='coding'
		else
			aichat --role='coding' "$*"
		fi
	}
	acs() {
		if [ $# -eq 0 ]; then
			echo_date "'acs' accepts [1..) arguments; got $#" && return 1
		elif [ $# -eq 1 ]; then
			aichat --role='coding' --session="$1"
		else
			__session="$1"
			shift
			aichat --role='coding' --session="${__session}" "$*"
		fi
	}
	as() {
		if [ $# -eq 0 ]; then
			echo_date "'as' accepts [1..) arguments; got $#" && return 1
		elif [ $# -eq 1 ]; then
			aichat --session="$1"
		else
			__session="$1"
			shift
			aichat --session="${__session}" "$*"
		fi
	}
fi

# bacon
if command -v bacon >/dev/null 2>&1; then
	bt() {
		if [ $# -eq 0 ]; then
			bacon nextest -- -- --nocapture
		elif [ $# -eq 1 ]; then
			bacon nextest -- "$1" -- --nocapture
		elif [ $# -eq 2 ]; then
			bacon nextest -- --test "$1" "$2" -- --nocapture
		else
			echo_date "'bt' accepts [0..2] arguments; got $#" && return 1
		fi
	}
fi

# bat
if command -v bat >/dev/null 2>&1; then
	cat() { bat "$@"; }
	catp() { bat --style=plain "$@"; }
	tf() {
		[ $# -ne 1 ] && echo_date "'tf' accepts 1 argument; got $#" && return 1
		__tf_base "$1" --language=log
	}
	tfp() {
		[ $# -ne 1 ] && echo_date "'tfp' accepts 1 argument; got $#" && return 1
		__tf_base "$1"
	}
	__tf_base() {
		__tf_base_file="$1"
		shift
		tail -F --lines=100 "${__tf_base_file}" | bat --paging=never --style=plain "$@"
	}
fi

# bottom
if command -v btm >/dev/null 2>&1; then
	htop() { btm "$@"; }
fi
bottom_toml() {
	[ $# -ne 0 ] && echo_date "'bottom_toml' accepts no arguments; got $#" && return 1
	${EDITOR} "${HOME}"/dotfiles/bottom/bottom.toml
}

# bump-my-version
if command -v bump-my-version >/dev/null 2>&1; then
	bump_patch() {
		[ $# -ne 0 ] && echo_date "'bump_patch' accepts no arguments; got $#" && return 1
		bump-my-version bump patch
	}
	bump_minor() {
		[ $# -ne 0 ] && echo_date "'bump_minor' accepts no arguments; got $#" && return 1
		bump-my-version bump minor
	}
	bump_major() {
		[ $# -ne 0 ] && echo_date "'bump_major' accepts no arguments; got $#" && return 1
		bump-my-version bump major
	}
	bump_set() {
		[ $# -ne 1 ] && echo_date "'bump_set' accepts 1 argument; got $#" && return 1
		bump-my-version replace --new-version "$1"
	}
fi

# cd
alias ~='cd "${HOME}"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
cd_cache() {
	[ $# -ne 0 ] && echo_date "'cd_cache' accepts no arguments; got $#" && return 1
	cd "${XDG_CACHE_HOME:-"${HOME}/.cache"}" || return $?
}
cd_config() {
	[ $# -ne 0 ] && echo_date "'cd_config' accepts no arguments; got $#" && return 1
	cd "${XDG_CONFIG_HOME:-"${HOME}/.config"}" || return $?
}
cddb() {
	[ $# -ne 0 ] && echo_date "'cddb' accepts no arguments; got $#" && return 1
	cd "${HOME}/Dropbox" || return $?
}
cddbt() {
	[ $# -ne 0 ] && echo_date "'cddbt' accepts no arguments; got $#" && return 1
	cd "${HOME}/Dropbox/Temporary" || return $?
}
cddf() {
	[ $# -ne 0 ] && echo_date "'cddf' accepts no arguments; got $#" && return 1
	cd "${HOME}/dotfiles" || return $?
}
cddl() {
	[ $# -ne 0 ] && echo_date "'cddl' accepts no arguments; got $#" && return 1
	cd "${HOME}/Downloads" || return $?
}
cdh() {
	[ $# -ne 0 ] && echo_date "'cdh' accepts no arguments; got $#" && return 1
	__cdh_dir="$(pwd)"
	cd / || return $?
	cd "${__cdh_dir}" || return $?
}
cdw() {
	[ $# -ne 0 ] && echo_date "'cdw' accepts no arguments; got $#" && return 1
	cd "${HOME}/work" || return $?
}
cdwg() {
	[ $# -ne 0 ] && echo_date "'cdwg' accepts no arguments; got $#" && return 1
	cd "${HOME}/work-gitlab" || return $?
}

# chmod
chmod_files() {
	[ $# -ne 1 ] && echo_date "'chmod_files' accepts 1 argument; got $#" && return 1
	find . -type f -exec chmod "$1" {} \;
}
chmod_dirs() {
	[ $# -ne 1 ] && echo_date "'chmod_dirs' accepts 1 argument; got $#" && return 1
	find . -type d -exec chmod "$1" {} \;
}
chown_files() {
	[ $# -ne 1 ] && echo_date "'chown_files' accepts 1 argument; got $#" && return 1
	find . -type f -exec chown "$1" {} \;
}
chown_dirs() {
	[ $# -ne 1 ] && echo_date "'chown_dirs' accepts 1 argument; got $#" && return 1
	find . -type d -exec chown "$1" {} \;
}

# coverage
open_cov() {
	[ $# -ne 0 ] && echo_date "'open_cov' accepts 1 argument; got $#" && return 1
	open .coverage/html/index.html
}

# cp
cpr() {
	[ $# -le 2 ] && echo_date "'cpr' accepts [2..) arguments; got $#" && return 1
	cp -r "$@"
}

# curl
if command -v curl >/dev/null 2>&1; then
	curl_sh() {
		[ $# -eq 0 ] && echo_date "'curl_sh' accepts [1..) arguments; got $#" && return 1
		__curl_sh_url="$1"
		shift
		curl -fsSL "${__curl_sh_url}" | sh -s -- "$@"
	}
fi

# debug
set_debug() {
	[ $# -ne 0 ] && echo_date "'set_debug' accepts no arguments; got $#" && return 1
	export DEBUG='1'
}
clear_debug() {
	[ $# -ne 0 ] && echo_date "'clear_debug' accepts no arguments; got $#" && return 1
	unset DEBUG
}

# dns
refresh_dns() {
	[ $# -ne 0 ] && echo_date "'refresh_dns' accepts no arguments; got $#" && return 1
	sudo dscacheutil -flushcache
	sudo killall -HUP mDNSResponder
}

# direnv
if command -v direnv >/dev/null 2>&1; then
	dea() {
		[ $# -ne 0 ] && echo_date "'dea' accepts no arguments; got $#" && return 1
		direnv allow
	}
fi

# docker
if command -v docker >/dev/null 2>&1; then
	dps() {
		[ $# -ne 0 ] && echo_date "'dps' accepts no arguments; got $#" && return 1
		docker ps
	}
fi

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# eza
if command -v eza >/dev/null 2>&1; then
	__eza_base() { eza --all --classify=always --group-directories-first "$@"; }
	__eza_long() { __eza_base --git --group --header --long --time-style=long-iso "$@"; }

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
		[ $# -eq 0 ] && echo_date "'__fd_base' accepts [1..) arguments; got $#" && return 1
		__fd_base_type=$1
		shift
		fd --hidden --type="${__fd_base_type}" "$@"
	}
fi

# find
clean_dirs() {
	if [ $# -eq 0 ]; then
		__clean_dirs_dir="$(pwd)"
	elif [ $# -eq 1 ]; then
		__clean_dirs_dir="$1"
	else
		echo_date "'clean_dirs' accepts [0..1] arguments; got $#" && return 1
	fi
	find "${__clean_dirs_dir}" -type d -delete
}

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

# hypothesis
hypothesis_ci() {
	[ $# -ne 0 ] && echo_date "'hypothesis_ci' accepts no arguments; got $#" && return 1
	export HYPOTHESIS_PROFILE='ci'
}
hypothesis_debug() {
	[ $# -ne 0 ] && echo_date "'hypothesis_debug' accepts no arguments; got $#" && return 1
	export HYPOTHESIS_PROFILE='debug'
}
hypothesis_default() {
	[ $# -ne 0 ] && echo_date "'hypothesis_default' accepts no arguments; got $#" && return 1
	export HYPOTHESIS_PROFILE='default'
}
hypothesis_dev() {
	[ $# -ne 0 ] && echo_date "'hypothesis_dev' accepts no arguments; got $#" && return 1
	export HYPOTHESIS_PROFILE='dev'
	hypothesis_no_shrink
}
hypothesis_no_shrink() {
	[ $# -ne 0 ] && echo_date "'hypothesis_no_shrink' accepts no arguments; got $#" && return 1
	export HYPOTHESIS_NO_SHRINK='1'
}

# local
__file="${HOME}/common.local.sh"
if [ -f "$__file" ]; then
	. "$__file"
fi

# marimo
marimo_toml() {
	[ $# -ne 0 ] && echo_date "'marimo_toml' accepts no arguments; got $#" && return 1
	${EDITOR} "${HOME}/dotfiles/marimo/marimo.toml"
}

# neovim
cd_plugins() {
	[ $# -ne 0 ] && echo_date "'cd_plugins' accepts no arguments; got $#" && return 1
	cd "${XDG_CONFIG_HOME:-"${HOME}/.config"}/nvim/lua/plugins" || return $?
}
clean_neovim() {
	[ $# -ne 0 ] && echo_date "'clean_neovim' accepts no arguments; got $#" && return 1
	rm -rf "${HOME}/.local/share/nvim/lazy"
	rm -rf "${HOME}.local/state/nvim"
	rm -rf "${XDG_CACHE_HOME:-"${HOME}/.cache"}/nvim"
}
plugins_dial() {
	[ $# -ne 0 ] && echo_date "'plugins_dial' accepts no arguments; got $#" && return 1
	${EDITOR} "${HOME}"/dotfiles/nvim/lua/plugins/dial.lua
}
snippets_python() {
	[ $# -ne 0 ] && echo_date "'snippets_python' accepts no arguments; got $#" && return 1
	${EDITOR} "${HOME}/dotfiles/nvim/snippets/python.json"
}
if command -v nvim >/dev/null 2>&1; then
	n() { nvim "$@"; }
fi

# path
echo_path() {
	[ $# -ne 0 ] && echo_date "'echo_path' accepts no arguments; got $#" && return 1
	echo_date "\$PATH:"
	echo "${PATH}" | tr ':' '\n' | nl
}

# ps + pgrep
pgrepf() {
	[ $# -ne 1 ] && echo_date "'pgrepf' accepts 1 argument; got $#" && return 1
	__pgrepf_pids=$(pgrep -f "$1" | tr '\n' ' ')
	if [ -z "${__pgrepf_pids}" ]; then
		echo_date "No process matched: $1" && return 1
	fi
	# shellcheck disable=SC2046
	ps -fp "${__pgrepf_pids}"
}
if command -v fzf >/dev/null 2>&1; then
	pgrep_kill() {
		[ $# -ne 1 ] && echo_date "'pgrep_kill' accepts 1 argument; got $#" && return 1
		__pgrep_kill_pids=$(pgrep -f "$1" | tr '\n' ' ')
		if [ -z "${__pgrep_kill_pids}" ]; then
			echo_date "No process matched '$1'" && return 0
		fi
		__pgrep_kill_results=$(ps -fp "${__pgrep_kill_pids}")
		__pgrep_kill_selected=$(
			printf '%s\n' "${__pgrep_kill_results}" |
				awk 'NR>1' |
				fzf --multi \
					--header-lines=0 \
					--prompt="Kill which $1 process? " \
					--preview="printf '%s\n' \"${__pgrep_kill_results}\" | head -1; echo {}; " \
					--preview-window=up:3:wrap
		)
		if [ -z "${__pgrep_kill_selected}" ]; then
			echo_date "No process selected" && return 0
		fi
		# shellcheck disable=SC2046
		set -- $(printf '%s\n' "${__pgrep_kill_selected}" | awk '{print $2}')
		echo_date "Killing PIDs: $*"
		kill -9 "$@"
	}
fi
if command -v watch >/dev/null 2>&1; then
	wpgrepf() {
		[ $# -ne 1 ] && echo_date "'wpgrepf' accepts 1 argument; got $#" && return 1
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

# reboot/shutdown
reboot_now() {
	[ $# -ne 0 ] && echo_date "'reboot_now' accepts no arguments; got $#" && return 1
	__run_shutdown 'Reboot' 'r'
}
shutdown_now() {
	[ $# -ne 0 ] && echo_date "'shutdown_now' accepts no arguments; got $#" && return 1
	__run_shutdown 'Shut down' 'h'
}
__run_shutdown() {
	[ $# -ne 2 ] && echo_date "'__run_shutdown' accepts no arguments; got $#" && return 1
	# $1 = desc
	# $2 = flag
	printf "%s now? [Y/n] " "$1"
	read -r __run_shutdown_response
	__run_shutdown_shutdown=$(printf "%s" "${__run_shutdown_response}" | tr '[:upper:]' '[:lower:]')
	if [ -z "${__run_shutdown_shutdown}" ] ||
		[ "${__run_shutdown_shutdown}" = "y" ] ||
		[ "${__run_shutdown_shutdown}" = "yes" ]; then
		sudo shutdown -"$1" now
	else
		echo_date "%s cancelled" "$2"
	fi
}

# tailscale
if command -v tailscale >/dev/null 2>&1 && command -v tailscaled >/dev/null 2>&1; then
	if command -v tailscaled >/dev/null 2>&1; then
		ts_down() {
			[ $# -ne 0 ] && echo_date "'ts_down' accepts no arguments; got $#" && return 1
			echo_date "Stopping 'tailscale'..."
			sudo tailscale down
			echo_date "Logging out of 'tailscale'..."
			sudo tailscale logout
			echo_date "Cleaning 'tailscaled'..."
			sudo tailscaled --cleanup
			echo_date "Killing 'tailscaled'..."
			sudo pkill tailscaled
		}
	fi
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
	tmkw() {
		[ $# -ne 0 ] && echo_date "'tmkw' accepts no arguments; got $#" && return 1
		tmux kill-window
	}
	tmux_attach() {
		if [ $# -eq 0 ]; then
			__tmux_attach_count="$(tmux ls 2>/dev/null | wc -l)"
			if [ "${__tmux_attach_count}" -eq 0 ]; then
				tmux new
				return
			elif [ "${__tmux_attach_count}" -eq 1 ]; then
				__tmux_attach_session="$(tmux ls | cut -d: -f1)"
			else
				echo_date "ERROR: %d sessions found" "${__tmux_attach_count}"
			fi
		elif [ $# -eq 1 ]; then
			__tmux_attach_session="$1"
		else
			echo_date "'tmux_attach' accepts [0..1] arguments; got $#" && return 1
		fi
		tmux attach -t "${__tmux_attach_session}"
	}
	tmux_current_window() {
		[ $# -ne 0 ] && echo_date "'tmux_current_window' accepts no arguments; got $#" && return 1
		tmux display-message -p '#S:#I'
	}
	tmux_detach() {
		[ $# -ne 0 ] && echo_date "'tmux_detach' accepts no arguments; got $#" && return 1
		tmux detach
	}
	tmux_kill_window() {
		[ $# -ne 0 ] && echo_date "'tmux_kill_window' accepts no arguments; got $#" && return 1
		tmux kill-window
	}
	tmux_list_keys() {
		if [ $# -eq 0 ]; then
			tmux list-keys
		elif [ $# -eq 1 ]; then
			tmux list-keys -T "$1"
		else
			echo_date "'tmux_list_keys' accepts [0..1] arguments; got $#" && return 1
		fi
	}
	tmux_ls() {
		[ $# -ne 0 ] && echo_date "'tmux_ls' accepts no arguments; got $#" && return 1
		tmux ls
	}
	# layouts
	if [ -z "$TMUX" ]; then
		__tmux_count="$(tmux ls 2>/dev/null | wc -l)"
		if [ "${__tmux_count}" -eq 0 ]; then
			tmux new
		elif [ "${__tmux_count}" -eq 1 ]; then
			tmux attach -t "$(tmux ls | cut -d: -f1)"
		else
			echo_date "Multiple 'tmux' sessions detected:"
			tmux ls
		fi
	fi
fi

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
			--help) usage ;;
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
			echo_date "'tsunami_serve' accepts no arguments; got $#" && return 1
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
	uvpld() {
		[ $# -ne 0 ] && echo_date "'uvpld' accepts no arguments; got $#" && return 1
		__uvpld '.project.dependencies[]'
		__uvpld '.["dependency-groups"].dev[]'
	}
	uvplo() {
		[ $# -ne 0 ] && echo_date "'uvplo' accepts no arguments; got $#" && return 1
		uv pip list --outdated
	}
	uvpu() { uv pip uninstall "$@"; }
	uvpyc() {
		if [ $# -eq 0 ]; then
			__uvpyc_dir="$(pwd)"
		elif [ $# -eq 1 ]; then
			__uvpyc_dir="$1"
		else
			echo_date "'uvpyc' accepts 1 argument; got $#" && return 1
		fi
		uv tool run pyclean "${__uvpyc_dir}"
		clean_dirs "${__uvpyc_dir}"
	}
	uvs() {
		[ $# -ne 0 ] && echo_date "'uvs' accepts no arguments; got $#" && return 1
		uv sync --upgrade
	}
	__uvpld() {
		[ $# -ne 1 ] && echo_date "'__uvpld' accepts 1 argument; got $#" && return 1
		__uvpld_deps=$(uv pip list --color=never)
		yq -r "$1" 'pyproject.toml' |
			sed 's/\[.*\]//; s/[ ,<>=!].*//' |
			while IFS= read -r __uvpld_dep; do
				[ -n "${__uvpld_dep}" ] || continue
				__uvpld_res=$(printf "%s\n" "${__uvpld_deps}" | grep --color=never -i "^${__uvpld_dep} ")
				if [ -n "${__uvpld_res}" ]; then
					echo "${__uvpld_res}"
				else
					echo "${__uvpld_dep} <--> N/A"
				fi
			done
	}
	if command -v watch >/dev/null 2>&1; then
		wuvpi() { watch --color --differences --interval=0.5 -- uv pip install "$@"; }
	fi
fi

# venv
venv_recreate() {
	[ $# -ne 0 ] && echo_date "'venv_recreate' accepts no arguments; got $#" && return 1
	__venv_recreate_file=$(ancestor file .envrc 2>/dev/null)
	__venv_recreate_code=$?
	if [ "${__venv_recreate_code}" -ne 0 ]; then
		echo_date "'venv_recreate' did not find an ancestor containg a file named '.envrc'" && return 1
	fi
	__venv_recreate_dir="${__venv_recreate_file}"/.venv
	if [ -d "${__venv_recreate_dir}" ]; then
		rm -rf "${__venv_recreate_dir}"
	fi
	cdh
}

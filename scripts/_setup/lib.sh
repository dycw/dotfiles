#!/usr/bin/env sh
# shellcheck disable=SC2034

set -eu

script_dir=$(dirname -- "$(realpath -- "$0")")
repo_root=$(dirname -- "$(dirname -- "${script_dir}")")
configs="${repo_root}/configs"
xdg_config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

fail() {
	log "$*" >&2
	exit 1
}

run_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	else
		sudo "$@"
	fi
}

add_brew_to_path() {
	if [ -x /opt/homebrew/bin/brew ]; then
		export PATH="/opt/homebrew/bin${PATH:+:${PATH}}"
	elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
		export PATH="/home/linuxbrew/.linuxbrew/bin${PATH:+:${PATH}}"
	elif [ -x /usr/local/bin/brew ]; then
		export PATH="/usr/local/bin${PATH:+:${PATH}}"
	fi
}

require_linux() {
	if [ ! -r /etc/os-release ]; then
		fail "'/etc/os-release' is not readable; exiting..."
	fi
	# shellcheck disable=SC1091
	. /etc/os-release
	if [ "${ID:-}" != debian ]; then
		fail "Unsupported Linux distribution '${ID:-unknown}'; exiting..."
	fi
}

determine_platform() {
	case "$(uname)" in
	Linux)
		require_linux
		platform=linux
		;;
	Darwin)
		platform=mac
		;;
	*)
		fail "Unsupported platform '$(uname)'; exiting..."
		;;
	esac
	add_brew_to_path
}

link_home() {
	src=$1
	dest=$2
	mkdir -p "$(dirname -- "${HOME}/${dest}")"
	ln -sfn "${src}" "${HOME}/${dest}"
}

link_config() {
	src=$1
	dest=$2
	mkdir -p "$(dirname -- "${xdg_config_home}/${dest}")"
	ln -sfn "${src}" "${xdg_config_home}/${dest}"
}

link_direct() {
	src=$1
	dest=$2
	mkdir -p "$(dirname -- "${dest}")"
	ln -sfn "${src}" "${dest}"
}

ensure_line_in_file() {
	line=$1
	path=$2
	if [ ! -f "${path}" ]; then
		printf '%s\n' "${line}" >"${path}"
		return
	fi
	if ! grep -Fqx "${line}" "${path}"; then
		printf '\n%s\n' "${line}" >>"${path}"
	fi
}

setup_ssh() {
	log "Setting up 'ssh'..."
	mkdir -p "${HOME}/.ssh"
	chmod 700 "${HOME}/.ssh"

	if [ ! -f "${HOME}/.ssh/authorized_keys" ]; then
		authorized_keys_url='https://raw.githubusercontent.com/dycw/authorized-keys/refs/heads/master/authorized_keys'
		curl -fssL "${authorized_keys_url}" >"${HOME}/.ssh/authorized_keys"
		chmod 600 "${HOME}/.ssh/authorized_keys"
	fi

	mkdir -p "${HOME}/.ssh/config.d"
	chmod 700 "${HOME}/.ssh/config.d"
	ensure_line_in_file 'Include ~/.ssh/config.d/*' "${HOME}/.ssh/config"
	chmod 600 "${HOME}/.ssh/config"
}

setup_bash() {
	log "Setting up 'bash'..."
	link_home "${configs}/bash/bashrc" .bashrc
	link_home "${configs}/bash/bash_profile" .bash_profile
	if command -v bash >/dev/null 2>&1; then
		bash_path=$(command -v bash)
		current_shell=''
		if [ "$(uname)" = Darwin ]; then
			current_shell=$(dscl . -read "/Users/${USER}" UserShell 2>/dev/null | awk '{print $2}' || true)
		elif command -v getent >/dev/null 2>&1; then
			current_shell=$(getent passwd "${USER}" 2>/dev/null | cut -d: -f7 || true)
		fi
		if [ -n "${current_shell}" ] && [ "${current_shell}" != "${bash_path}" ]; then
			if [ -t 0 ]; then
				chsh -s "${bash_path}" || true
			else
				log "'bash' is not the default shell; run \"chsh -s '${bash_path}'\""
			fi
		fi
	fi
}

#!/usr/bin/env sh

set -eu

###############################################################################

link() {
	src="$(dirname -- "$(realpath -- "$0")")/$1"
	dest="${HOME}/$2"
	mkdir -p "$(dirname -- "${dest}")"
	ln -sfn "${src}" "${dest}"
}

###############################################################################

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up 'bash'..."

link bashrc .bashrc
link bash_profile .bash_profile

if command -v bash >/dev/null 2>&1; then
	bash_path=$(command -v bash)
	current_shell=$(getent passwd "${USER}" 2>/dev/null | cut -d: -f7 || true)
	if [ -z "${current_shell}" ] && [ "$(uname)" = Darwin ]; then
		current_shell=$(dscl . -read "/Users/${USER}" UserShell 2>/dev/null | awk '{print $2}' || true)
	fi
	if [ -n "${current_shell}" ] && [ "${current_shell}" != "${bash_path}" ]; then
		if [ -t 0 ]; then
			chsh -s "${bash_path}" || true
		else
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'bash' is not the default shell; run \"chsh -s '${bash_path}'\""
		fi
	fi
fi

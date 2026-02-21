#!/usr/bin/env sh

set -eu

###############################################################################

link() {
	src="$(dirname -- "$(realpath -- "$0")")/$1"
	dest="${XDG_CONFIG_HOME:-${HOME}/.config}/$2"
	mkdir -p "$(dirname -- "${dest}")"
	ln -sfn "${src}" "${dest}"
}

###############################################################################

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up 'fish'..."

case "$(uname -s)" in
Darwin)
	USER_SHELL=$(dscl . -read "/Users/${USER}" UserShell | awk '{print $2}')
	;;
Linux)
	USER_SHELL=$(getent passwd "${USER}" | cut -d: -f7)
	;;
*)
	echo "Unsupported OS '$(uname -s)'; exiting..." >&2
	exit 1
	;;
esac

if command -v fish >/dev/null 2>&1 && [ "${USER_SHELL}" != "$(which fish)" ]; then
	chsh -s "$(which fish)"
fi

link shell.fish fish/conf.d/fish.fish

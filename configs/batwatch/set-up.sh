#!/usr/bin/env sh

set -eu

###############################################################################

link() {
	src="$(dirname -- "$(realpath -- "$0")")/$1"
	dest="${XDG_CONFIG_HOME:-${HOME}/.config}/$2"
	mkdir -p "$(dirname -- "${dest}")"
	ln -sfn "${src}" "${dest}"
	mkdir -p "$(dirname -- "$2")"
	script_dir=$(dirname -- "$(realpath -- "$0")")
	ln -sfn "${script_dir}/$1" "${XDG_CONFIG_HOME:-${HOME}/.config}/$2"
}

###############################################################################

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up 'batwatch'..."

link shell.fish fish/conf.d/batwatch.fish

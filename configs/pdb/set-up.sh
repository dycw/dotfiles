#!/usr/bin/env sh

set -eu

###############################################################################

link() {
	mkdir -p "$(dirname -- "$2")"
	script_dir=$(dirname -- "$(realpath -- "$0")")
	ln -sfn "${script_dir}/$1" "${HOME}/$2"
}

###############################################################################

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up 'pdb'..."

link pdbrc .pdbrc

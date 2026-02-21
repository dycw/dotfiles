#!/usr/bin/env sh

set -eu

###############################################################################

link() {
	mkdir -p "$(dirname -- "$2")"
	script_dir=$(dirname -- "$(realpath -- "$0")")
	ln -sfn "${script_dir}/$1" "$2"
}

###############################################################################

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up 'ipython'..."

link shell.fish "${XDG_CONFIG_HOME:-${HOME}/.config}/fish/conf.d/ipython.fish"
link ipython_config.py "${HOME}/.ipython/profile_default/ipython_config.py"
link startup.py "${HOME}/.ipython/profile_default/startup/startup.py"

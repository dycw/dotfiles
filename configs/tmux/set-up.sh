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

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up 'tmux'..."

link shell.fish fish/conf.d/tmux.fish
link tmux.conf.local tmux/tmux.conf.local
link .tmux/.tmux.conf tmux/tmux.conf

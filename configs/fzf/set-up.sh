#!/usr/bin/env sh

set -eu

###############################################################################

script_dir=$(dirname -- "$(realpath -- "$0")")

link() {
	dest="${XDG_CONFIG_HOME:-${HOME}/.config}/$2"
	mkdir -p "$(dirname -- "${dest}")"
	ln -sfn "$1" "${dest}"
}

link_here() {
	link "${script_dir}/$1" "$2"
}

###############################################################################

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up 'fzf'..."

link_here shell.fish fish/conf.d/fzf.fish
link_here shell.sh posix/fzf.sh
link_here fzf.fish/conf.d/fzf.fish fish/conf.d/fzf-fish-plugin.fish
for file in "${script_dir}"/fzf.fish/functions/*.fish; do
	[ -e "$file" ] || continue
	name=$(basename -- "${file}")
	link "${file}" "fish/functions/${name}"
done

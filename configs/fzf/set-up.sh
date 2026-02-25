#!/usr/bin/env sh

set -eu

###############################################################################

script_dir=$(dirname -- "$(realpath -- "$0")")

link() {
	dest="${XDG_CONFIG_HOME:-${HOME}/.config}/$2"
	mkdir -p "$(dirname -- "${dest}")"
	ln -sfn "$1" "${dest}"
}

link_adj() {
	link "${script_dir}/$1" "$2"
}

link_submodule_dir() {
	dir="$1"
	for file in "${script_dir}"/fzf.fish/"${dir}"/*.fish; do
		if [ -e "${file}" ]; then
			name=$(basename -- "${file}")
			if [ "${name}" = fzf.fish ]; then
				name_use=fzf-fish-plugin.fish
			else
				name_use="${name}"
			fi
			link "${file}" "fish/${dir}/${name_use}"
		fi
	done
}

###############################################################################

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up 'fzf'..."

link_adj shell.fish fish/conf.d/fzf.fish
link_adj shell.sh posix/fzf.sh
for dir in completions conf.d functions; do
	link_submodule_dir "${dir}"
done

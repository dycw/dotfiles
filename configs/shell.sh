#!/usr/bin/env sh

set -eu

if [ -d "${HOME}/.local/bin" ]; then
	export PATH="${HOME}/.local/bin${PATH:+:${PATH}}"
fi

export XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"

if [ "${-#*i}" = "$-" ]; then
	return
fi

if command -v vim >/dev/null 2>&1; then
	export EDITOR=vim
	export VISUAL=vim
elif command -v vi >/dev/null 2>&1; then
	export EDITOR=vi
	export VISUAL=vi
elif command -v nano >/dev/null 2>&1; then
	export EDITOR=nano
	export VISUAL=nano
fi

if ! command -v eza >/dev/null 2>&1; then
	l() { la "$@"; }
	la() { ls -ahl --color=always "$@"; }
fi

case "$0" in
/*) config_self_path=$0 ;;
*) config_self_path=$(pwd -P)/$0 ;;
esac
script_dir=$(CDPATH='' cd -- "$(dirname -- "${config_self_path}")" && pwd -P)
PATH_DOTFILES=$(CDPATH='' cd -- "${script_dir}/.." && pwd -P)
export PATH_DOTFILES

for file in "${HOME}"/.mode.sw*; do
	if [ -e "${file}" ]; then
		rm -v -- "${file}"
	fi
done

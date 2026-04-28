#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v wezterm >/dev/null 2>&1; then
	return
fi

edit_wezterm_lua() {
	"${EDITOR}" "${PATH_DOTFILES}/configs/wezterm/wezterm.lua"
}

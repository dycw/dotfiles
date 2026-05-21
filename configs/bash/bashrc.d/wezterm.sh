# shellcheck shell=bash
if command -v wezterm >/dev/null 2>&1; then
	edit_wezterm_lua() { "${EDITOR}" "${PATH_DOTFILES}/configs/wezterm.lua"; }
fi

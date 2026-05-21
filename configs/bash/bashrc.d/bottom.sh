# shellcheck shell=bash
if command -v btm >/dev/null 2>&1; then
	edit_bottom_toml() { "${EDITOR}" "${PATH_DOTFILES}/configs/bottom.toml"; }
fi

# shellcheck shell=sh
if command -v btm >/dev/null 2>&1; then

	edit_bottom_toml() { "${EDITOR}" "${PATH_DOTFILES:-${HOME}/dotfiles}/configs/bottom.toml"; }

fi

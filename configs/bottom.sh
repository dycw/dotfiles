#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v btm >/dev/null 2>&1; then
	return
fi

edit_bottom_toml() {
	"${EDITOR}" "${PATH_DOTFILES}/configs/bottom/bottom.toml"
}

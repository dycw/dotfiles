#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v ghostty >/dev/null 2>&1; then
	return
fi

edit_ghostty_config() {
	"${EDITOR}" "${PATH_DOTFILES}/configs/ghostty/config"
}

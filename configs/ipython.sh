#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ]; then
	return
fi

edit_ipython_startup() {
	"${EDITOR}" "${PATH_DOTFILES}/configs/ipython/startup.py"
}

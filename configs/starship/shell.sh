#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v starship >/dev/null 2>&1; then
	return
fi

###############################################################################

if [ -n "${BASH_VERSION-}" ]; then
	eval "$(starship init bash)"
elif [ -n "${ZSH_VERSION-}" ]; then
	eval "$(starship init zsh)"
fi

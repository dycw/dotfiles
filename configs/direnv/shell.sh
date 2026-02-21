#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v direnv >/dev/null 2>&1; then
	return
fi

###############################################################################

if [ -n "${BASH_VERSION-}" ]; then
	eval "$(direnv hook bash)"
elif [ -n "${ZSH_VERSION-}" ]; then
	eval "$(direnv hook zsh)"
fi

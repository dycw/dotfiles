#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v fzf >/dev/null 2>&1; then
	return
fi

###############################################################################

if [ -n "${BASH_VERSION-}" ]; then
	eval "$(fzf --bash)"
elif [ -n "${ZSH_VERSION-}" ]; then
	eval "$(fzf --zsh)"
fi

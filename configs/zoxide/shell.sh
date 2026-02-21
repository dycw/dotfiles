#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v zoxide >/dev/null 2>&1; then
	return
fi

###############################################################################

if [ -n "${BASH_VERSION-}" ]; then
	eval "$(zoxide init --cmd j bash)"
elif [ -n "${ZSH_VERSION-}" ]; then
	eval "$(zoxide init --cmd j zsh)"
fi

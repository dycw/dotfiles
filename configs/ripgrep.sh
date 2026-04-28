#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v rg >/dev/null 2>&1; then
	return
fi

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/ripgreprc"

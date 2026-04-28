#!/usr/bin/env sh

set -eu

if command -v brew >/dev/null 2>&1 && brew --prefix node >/dev/null 2>&1; then
	node_prefix=$(brew --prefix node)
	if [ -d "${node_prefix}/bin" ]; then
		export PATH="${node_prefix}/bin${PATH:+:${PATH}}"
	fi
fi

if [ -d "${HOME}/.local/share/nvm/v25.6.1/bin" ]; then
	export PATH="${HOME}/.local/share/nvm/v25.6.1/bin${PATH:+:${PATH}}"
fi

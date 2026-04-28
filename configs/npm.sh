#!/usr/bin/env sh

set -eu

if [ -d "${HOME}/.npm-global/bin" ]; then
	export PATH="${HOME}/.npm-global/bin${PATH:+:${PATH}}"
fi

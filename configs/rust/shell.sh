#!/usr/bin/env sh

set -eu

if [ -d "${HOME}/.cargo/bin" ]; then
	export PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}"
fi

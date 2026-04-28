#!/usr/bin/env sh

set -eu

if command -v brew >/dev/null 2>&1 && brew --prefix postgresql@18 >/dev/null 2>&1; then
	postgres_prefix=$(brew --prefix postgresql@18)
	if [ -d "${postgres_prefix}/bin" ]; then
		export PATH="${postgres_prefix}/bin${PATH:+:${PATH}}"
	fi
fi

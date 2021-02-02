#!/usr/bin/env bash

if command -v zoxide >/dev/null 2>&1; then
	eval "$(zoxide init bash)"
else
	printf "zoxide not found\n"
fi

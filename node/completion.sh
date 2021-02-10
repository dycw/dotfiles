#!/usr/bin/env bash

if command -v npm >/dev/null 2>&1; then
	# shellcheck source=/dev/null
	source <(npm completion)
fi

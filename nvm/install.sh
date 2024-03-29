#!/usr/bin/env bash

echo "$(date '+%Y-%m-%d %H:%M:%S'): Running nvm/install.sh..."

export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
if ! [ -d "$NVM_DIR" ]; then
	# shellcheck source=/dev/null
	source "$(git rev-parse --show-toplevel)/curl/install.sh"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh |
		bash
	# shellcheck source=/dev/null
	source "$NVM_DIR/nvm.sh"
fi

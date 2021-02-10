#!/usr/bin/env bash

file="$(
	cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
	find "$(git rev-parse --show-toplevel)" -path \*/bash/completion-install.sh -type f
)"
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file" tmux https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux
else
	echo "completion-install.sh not found"
fi

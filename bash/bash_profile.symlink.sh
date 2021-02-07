#!/usr/bin/env bash
# symlink=~/.bash_profile

root=$(
	cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
	git rev-parse --show-toplevel
)
mapfile -t files < <(find "$root" -name "env.sh" -type f)
for file in "${files[@]}"; do
	# shellcheck source=/dev/null
	source "$file"
done

# https://unix.stackexchange.com/a/541352
if [ -n "$BASH_VERSION" ]; then
	# include .bashrc if it exists
	if [ -f "$HOME/.bashrc" ]; then
		# shellcheck source=/dev/null
		. "$HOME/.bashrc"
	fi
fi

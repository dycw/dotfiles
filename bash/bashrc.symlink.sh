#!/usr/bin/env bash
# symlink=~/.bashrc

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# If interactive
root="$(
	cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
	git rev-parse --show-toplevel
)"

# bin/
mapfile -t paths < <(find "$root" -name "bin" -type d)
for path in "${paths[@]}"; do
	PATH="$path${PATH:+:${PATH}}"
done

# init, aliases, completion
declare -a names=("init" "aliases" "completion")
for name in "${names[@]}"; do
	mapfile -t files < <(find "$root" -name "$name.sh" -type f)
	for file in "${files[@]}"; do
		# shellcheck source=/dev/null
		source "$file"
	done
done

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

# bin/, then init, then alias
mapfile -t paths < <(find "$root" -name "bin" -type d)
for path in "${paths[@]}"; do
	PATH="$path${PATH:+:${PATH}}"
done

mapfile -t files < <(find "$root" -name "init.sh" -type f)
for file in "${files[@]}"; do
	# shellcheck source=/dev/null
	source "$file"
done

mapfile -t files < <(find "$root" -name "aliases.sh" -type f)
for file in "${files[@]}"; do
	# shellcheck source=/dev/null
	source "$file"
done

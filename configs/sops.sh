#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v sops >/dev/null 2>&1; then
	return
fi

sops_new() {
	if [ "$#" -lt 2 ]; then
		echo "'sops_new' expected [2..) arguments AGE FILE; got $#" >&2
		return 1
	fi
	age=$1
	file=$2
	sops edit --age "${age}" "${file}"
}

#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v curl >/dev/null 2>&1; then
	return
fi

curl_sh() {
	if [ "$#" -lt 1 ]; then
		echo "'curl_sh' expected [1..) arguments URL; got $#" >&2
		return 1
	fi
	url=$1
	shift
	curl -fsSL "${url}" | sh -s -- "$@"
}

curl_ip() {
	curl api.ipify.org
}

#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ]; then
	return
fi

coverage() {
	open .coverage/html/index.html
}

p3() {
	python3 "$@"
}

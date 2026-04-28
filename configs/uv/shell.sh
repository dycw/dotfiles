#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v uv >/dev/null 2>&1; then
	return
fi

pyc() {
	uvx pyclean --debris=all .
}

uvbp() {
	if [ "$#" -lt 1 ]; then
		echo "'uvbp' expected [1..) arguments TOKEN; got $#" >&2
		return 1
	fi
	uv build --wheel --clear
	uv publish --token "$1"
}

uvl() {
	if [ "$#" -eq 0 ]; then
		uv pip list
	else
		uv pip list | grep -i "$1"
	fi
}

uvo() {
	uv pip list --outdated
}

uvrp() {
	uv run python -m "$@"
}

uvrpd() {
	uv run python -m pdb --command continue -m "$@"
}

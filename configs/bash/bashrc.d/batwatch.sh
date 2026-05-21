# shellcheck shell=bash
if command -v batwatch >/dev/null 2>&1; then
	bw() { batwatch -n0.5 "$@"; }
fi

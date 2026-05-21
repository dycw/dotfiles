# shellcheck shell=bash
if command -v ruff >/dev/null 2>&1; then
	rw() { ruff check -w "$@"; }
fi

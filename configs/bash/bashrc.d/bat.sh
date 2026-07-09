# shellcheck shell=sh
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
	bat() {
		if command -v bat >/dev/null 2>&1; then
			command bat "$@"
		else
			command batcat "$@"
		fi
	}
	cat() { bat "$@"; }
	catp() { bat --style=plain "$@"; }
fi

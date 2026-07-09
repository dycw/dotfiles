# shellcheck shell=sh
if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
	fd() {
		if command -v fd >/dev/null 2>&1; then
			command fd "$@"
		else
			command fdfind "$@"
		fi
	}
	__fd_type() {
		if [ "$#" -lt 1 ]; then
			echo "'__fd_type' expected [1..) arguments TYPE; got $#" >&2
			return 1
		fi
		type=$1
		shift
		fd --hidden --type="${type}" "$@"
	}
	fdd() { __fd_type directory "$@"; }
	fdf() { __fd_type file "$@"; }
fi

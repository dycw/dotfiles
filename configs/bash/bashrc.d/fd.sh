# shellcheck shell=sh
if [ -z "${__dotfiles_fd_command:-}" ]; then
	if command -v fdfind >/dev/null 2>&1; then
		__dotfiles_fd_command=fdfind
	elif command -v fd >/dev/null 2>&1; then
		__dotfiles_fd_command=fd
	fi
fi

if [ -n "${__dotfiles_fd_command:-}" ]; then
	fd() { command "${__dotfiles_fd_command}" "$@"; }
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

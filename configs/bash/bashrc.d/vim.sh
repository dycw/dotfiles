# shellcheck shell=sh
if command -v vim >/dev/null 2>&1; then
	v() { vim "$@"; }

	trunc_vim() {
		[ "$#" -eq 0 ] || truncate -s0 "$@" || return
		vim "$@"
	}
fi

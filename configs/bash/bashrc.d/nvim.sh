# shellcheck shell=sh
if command -v nvim >/dev/null 2>&1; then
	v() { nvim "$@"; }

	trunc_nvim() {
		[ "$#" -eq 0 ] || truncate -s0 "$@" || return
		nvim "$@"
	}
fi

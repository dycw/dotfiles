# shellcheck shell=sh
if command -v vim >/dev/null 2>&1; then
	v() { vim "$@"; }
fi

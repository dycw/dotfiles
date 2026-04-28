#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v tmux >/dev/null 2>&1; then
	return
fi

ta() {
	if [ "$#" -gt 1 ]; then
		echo "'ta' expected [0..1] arguments SESSION; got $#" >&2
		return 1
	fi
	if [ "$#" -eq 1 ]; then
		tmux attach -t "$1"
		return
	fi
	if ! tmux ls >/dev/null 2>&1; then
		tmux new
		return
	fi
	count=$(tmux ls 2>/dev/null | wc -l | tr -d ' ')
	case "${count}" in
	0) tmux new ;;
	1) tmux attach ;;
	*)
		echo "'ta' expected at most 1 existing session; got ${count}" >&2
		return 1
		;;
	esac
}

tmux_reload() {
	tmux source-file "${XDG_CONFIG_HOME:-${HOME}/.config}/tmux/tmux.conf"
}

#!/usr/bin/env bash
# shellcheck disable=SC1090

path="$HOME/.cargo/env"
if [ -f "$path" ]; then
	source "$path"
else
	timed_log "Unable to find %s\n" "$path"
fi

#!/usr/bin/env bash
# shellcheck source=/dev/null

__bashrc="$HOME/.bashrc"
if [ -f "$__bashrc" ]; then
	source "$__bashrc"
fi

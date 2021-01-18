#!/usr/bin/env bash

if ! command -v zoxide >/dev/null 2>&1; then
	timed_log "zoxide not found; installing...\n"
	curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/master/install.sh | sh
	timed_log "zoxide installed\n"
fi

#!/usr/bin/env bash

if ! command -v elm >/dev/null 2>&1; then
	timed_log "elm not found; installing...\n"
	elm_gz="/tmp/elm.gz"
	curl -L -o "$elm_gz" https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
	gunzip "$elm_gz"
	tmp_elm="/tmp/elm"
	chmod +x "$tmp_elm"
	sudo mv "$tmp_elm" /usr/local/bin/
	timed_log "elm installed\n"
fi

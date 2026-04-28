#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ]; then
	return
fi

__pyright() {
	if command -v pyright >/dev/null 2>&1; then
		pyright .
		return
	fi
	if command -v uv >/dev/null 2>&1; then
		if [ -f .venv/bin/python ]; then
			uv tool run pyright --pythonpath .venv/bin/python .
		else
			uv tool run pyright .
		fi
		return
	fi
	echo "'__pyright' expected 'pyright' or 'uv' to be available; got neither" >&2
	return 1
}

pyr() {
	__pyright "$@"
}

wpyr() {
	if ! command -v watchexec >/dev/null 2>&1; then
		return 0
	fi
	cmd="cd $(pwd); pyright"
	watchexec --exts json --exts py --exts toml --exts yaml --shell bash -- "${cmd}"
}

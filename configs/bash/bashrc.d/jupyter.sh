# shellcheck shell=bash
if command -v uv >/dev/null 2>&1; then
	jl() {
		local args=()
		for _arg in "$@"; do args+=(--with "${_arg}"); done
		uv run --with dycw-utilities --with jupyterlab --with jupyterlab-vim "${args[@]}" jupyter lab
	}
fi

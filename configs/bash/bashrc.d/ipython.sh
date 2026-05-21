# shellcheck shell=bash
edit_ipython_startup() { "${EDITOR}" "${PATH_DOTFILES}/configs/ipython/startup.py"; }

if command -v uv >/dev/null 2>&1; then
	ipy() {
		local args=()
		for _arg in "$@"; do args+=(--with "${_arg}"); done
		uv run --with dycw-utilities --with ipython "${args[@]}" ipython
	}
fi

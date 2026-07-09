# shellcheck shell=sh
edit_ipython_startup() { "${EDITOR}" "${PATH_DOTFILES}/configs/ipython/startup.py"; }

if command -v uv >/dev/null 2>&1; then
	ipy() {
		_uv_with_args=''
		set -- dycw-utilities ipython "$@"
		while [ "$#" -gt 0 ]; do
			_uv_arg=$(printf "%s\n" "$1" | sed "s/'/'\\\\''/g")
			_uv_with_args="${_uv_with_args:+${_uv_with_args} }--with '${_uv_arg}'"
			shift
		done
		eval "uv run ${_uv_with_args} ipython"
		unset _uv_arg _uv_with_args
	}
fi

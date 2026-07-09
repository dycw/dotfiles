# shellcheck shell=sh
if command -v uv >/dev/null 2>&1; then
	jl() {
		_uv_with_args=''
		set -- dycw-utilities jupyterlab jupyterlab-vim "$@"
		while [ "$#" -gt 0 ]; do
			_uv_arg=$(printf "%s\n" "$1" | sed "s/'/'\\\\''/g")
			_uv_with_args="${_uv_with_args:+${_uv_with_args} }--with '${_uv_arg}'"
			shift
		done
		eval "uv run ${_uv_with_args} jupyter lab"
		unset _uv_arg _uv_with_args
	}
fi

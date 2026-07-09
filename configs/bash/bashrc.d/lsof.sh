# shellcheck shell=sh
if command -v lsof >/dev/null 2>&1; then
	check_port() {
		if [ "$#" -lt 1 ]; then
			echo "'check-port' expected [1..) argument PORT; got $#" >&2
			return 1
		fi
		lsof -i :"$1"
	}
fi

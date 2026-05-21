# shellcheck shell=bash disable=SC2124
mv() {
	if [ "$#" -lt 2 ]; then
		echo "'mv' expected [2..) arguments SOURCE ... TARGET; got $#" >&2
		return 1
	fi
	local target="${@:$#:1}"
	if [ "$#" -eq 2 ]; then
		case "${target}" in
		*/) command mkdir -p "${target}" ;;
		*) command mkdir -p "$(dirname -- "${target}")" ;;
		esac
	else
		command mkdir -p "${target}"
	fi
	command mv -fv "$@"
}

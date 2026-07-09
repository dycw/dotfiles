# shellcheck shell=sh
cp() {
	if [ "$#" -lt 2 ]; then
		echo "'cp' expected [2..) arguments SOURCE ... TARGET; got $#" >&2
		return 1
	fi
	for target; do :; done
	if [ "$#" -eq 2 ]; then
		case "${target}" in
		*/) command mkdir -p "${target}" ;;
		*) command mkdir -p "$(dirname -- "${target}")" ;;
		esac
	else
		command mkdir -p "${target}"
	fi
	command cp -frv "$@"
}

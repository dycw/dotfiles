# shellcheck shell=bash
touch() {
	for _file in "$@"; do
		command mkdir -p "$(dirname -- "${_file}")"
		command touch "${_file}"
	done
}

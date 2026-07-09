# shellcheck shell=sh
rm() {
	for _arg in "$@"; do
		if [ "${_arg}" = ".git" ]; then
			printf "Are you sure you want to remove '.git'? (y/N) "
			read -r _reply
			case "${_reply}" in
			y | Y) ;;
			*)
				echo "Exiting..." >&2
				return 1
				;;
			esac
		fi
	done
	command rm -frv "$@"
}

unlink() { for _file in "$@"; do command unlink "${_file}"; done; }

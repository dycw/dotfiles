# shellcheck shell=sh
chown_files() {
	if [ "$#" -lt 1 ]; then
		echo "'chown-files' expected [1..) arguments OWNER; got $#" >&2
		return 1
	fi
	find . -type f -exec chown "$1" {} \;
}
chown_dirs() {
	if [ "$#" -lt 1 ]; then
		echo "'chown-dirs' expected [1..) arguments OWNER; got $#" >&2
		return 1
	fi
	find . -type d -exec chown "$1" {} \;
}

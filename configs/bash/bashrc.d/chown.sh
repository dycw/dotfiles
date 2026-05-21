# shellcheck shell=bash
chown-files() {
	if [ "$#" -lt 1 ]; then
		echo "'chown-files' expected [1..) arguments OWNER; got $#" >&2
		return 1
	fi
	find . -type f -exec chown "$1" {} \;
}
chown-dirs() {
	if [ "$#" -lt 1 ]; then
		echo "'chown-dirs' expected [1..) arguments OWNER; got $#" >&2
		return 1
	fi
	find . -type d -exec chown "$1" {} \;
}

# shellcheck shell=bash
chmod-files() {
	if [ "$#" -lt 1 ]; then
		echo "'chmod-files' expected [1..) arguments MODE; got $#" >&2
		return 1
	fi
	find . -type f -print0 | xargs -0 chmod "$1"
}
chmod-dirs() {
	if [ "$#" -lt 1 ]; then
		echo "'chmod-dirs' expected [1..) arguments MODE; got $#" >&2
		return 1
	fi
	find . -type d -print0 | xargs -0 chmod "$1"
}

# shellcheck shell=sh
eg() {
	if [ "$#" -lt 1 ]; then
		echo "'eg' expected [1..) arguments PATTERN; got $#" >&2
		return 1
	fi
	env | sort | grep -i "$@"
}

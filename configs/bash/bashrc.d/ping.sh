# shellcheck shell=sh
ping_ts() {
	count='' interval=2 deadline=2 destination=''
	while [ "$#" -gt 0 ]; do
		case "$1" in
		-c | --count)
			count="$2"
			shift 2
			;;
		-i | --interval)
			interval="$2"
			shift 2
			;;
		-w | --deadline)
			deadline="$2"
			shift 2
			;;
		*)
			destination="$1"
			shift
			;;
		esac
	done
	if [ -z "${destination}" ]; then
		echo "'ping-ts' expected [1..) arguments ... DESTINATION; got 0" >&2
		return 1
	fi
	if [ -n "${count}" ]; then
		ping -O -c "${count}" -i "${interval}" -W "${deadline}" "${destination}"
	else
		ping -O -i "${interval}" -W "${deadline}" "${destination}"
	fi | while IFS= read -r pong; do
		printf '[%s/%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${destination}" "${pong}"
	done
}

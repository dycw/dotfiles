#!/usr/bin/env sh
# shellcheck source=/dev/null

# tsunami
for __name in client server; do
	__dir="${HOME}"/work/tsunami-udp/tsunami-udp/"${__name}"
	case ":${PATH}:" in
	*:"${__dir}":*) ;;
	*) export PATH="${__dir}:${PATH}" ;;
	esac
done

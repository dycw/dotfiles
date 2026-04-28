#!/bin/sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

# shellcheck disable=SC1090,SC1091
. "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/common.sh"

found=0
for test_script in "${repo_root}"/tests/*.sh; do
	[ -e "${test_script}" ] || continue
	case "$(basename -- "${test_script}")" in
	_*) continue ;;
	esac
	found=1
	log "running $(basename -- "${test_script}")"
	sh "${test_script}"
done

[ "${found}" -eq 1 ] || fail 'no test scripts found under tests/*.sh'

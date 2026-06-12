# shellcheck shell=bash

gitea_pkg_purge() {
	if [ "$#" -ne 1 ]; then
		echo "usage: gitea_pkg_purge <gitea package url>" >&2
		return 1
	fi
	if [ -z "${TOKEN:-}" ]; then
		echo "TOKEN is not set" >&2
		return 1
	fi
	if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
		echo "gitea_pkg_purge requires curl and jq" >&2
		return 1
	fi

	local url=$1
	local path=${url#http://}
	path=${path#https://}
	path=${path#*/}

	local old_ifs=${IFS}
	IFS=/
	# shellcheck disable=SC2086
	set -- ${path}
	IFS=${old_ifs}

	if [ "$#" -lt 5 ]; then
		echo "invalid url" >&2
		return 1
	fi
	if [ "$2" != "-" ] || [ "$3" != "packages" ]; then
		echo "unrecognized gitea package url shape" >&2
		return 1
	fi

	local owner=$1
	local type=$4
	local name=$5
	case ${type} in
	cargo | generic) ;;
	*)
		echo "unsupported package type: ${type}" >&2
		echo "this function currently handles: cargo, generic" >&2
		return 1
		;;
	esac

	local list_url="https://gitea.ai/api/v1/packages/${owner}/${type}/${name}?limit=100"
	local data
	data=$(curl -fsS -H "Authorization: token ${TOKEN}" "${list_url}") || {
		echo "failed to fetch versions" >&2
		return 1
	}
	if ! printf '%s' "${data}" | jq -e 'type == "array"' >/dev/null; then
		echo "unexpected API response:" >&2
		printf '%s\n' "${data}" >&2
		return 1
	fi

	local versions
	versions=$(printf '%s' "${data}" | jq -r '.[].version')
	if [ -z "${versions}" ]; then
		echo "no versions found"
		return 0
	fi

	printf 'owner:   %s\n' "${owner}"
	printf 'type:    %s\n' "${type}"
	printf 'package: %s\n\n' "${name}"
	echo "versions:"
	printf '%s\n' "${versions}" | sed 's/^/  /'
	echo

	printf 'delete ALL versions? [y/N] '
	local confirm
	read -r confirm
	if [ "${confirm}" != y ]; then
		echo aborted
		return 0
	fi

	local deleted=0
	while :; do
		versions=$(printf '%s' "${data}" | jq -r '.[].version')
		[ -n "${versions}" ] || break

		local version del_url code
		while IFS= read -r version; do
			echo "deleting ${version}"
			case ${type} in
			generic) del_url="https://gitea.ai/api/packages/${owner}/generic/${name}/${version}" ;;
			cargo) del_url="https://gitea.ai/api/v1/packages/${owner}/cargo/${name}/${version}" ;;
			esac
			code=$(curl -s -o /dev/null -w '%{http_code}' \
				-X DELETE \
				-H "Authorization: token ${TOKEN}" \
				"${del_url}")
			echo "  -> HTTP ${code}"
			deleted=$((deleted + 1))
		done <<<"${versions}"

		data=$(curl -fsS -H "Authorization: token ${TOKEN}" "${list_url}") || {
			echo "failed to fetch versions" >&2
			return 1
		}
		if ! printf '%s' "${data}" | jq -e 'type == "array"' >/dev/null; then
			echo "unexpected API response:" >&2
			printf '%s\n' "${data}" >&2
			return 1
		fi
	done

	echo
	printf 'deleted %s versions\n' "${deleted}"
	echo "remaining versions:"
	printf '%s' "${data}" | jq -r '.[].version'
}

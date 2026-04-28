#!/bin/sh
# shellcheck disable=SC2154

set -eu

# shellcheck disable=SC1090,SC1091
. "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/common.sh"

parse_semver_into() {
	prefix=$1
	raw=$2
	case "${raw}" in
	'' | *[!0-9.]*) return 1 ;;
	esac
	old_ifs=${IFS}
	IFS=.
	# shellcheck disable=SC2086
	set -- ${raw}
	IFS=${old_ifs}
	[ "$#" -eq 3 ] || return 1
	for part in "$1" "$2" "$3"; do
		case "${part}" in
		'' | *[!0-9]*) return 1 ;;
		esac
	done
	eval "${prefix}_major=\$1"
	eval "${prefix}_minor=\$2"
	eval "${prefix}_patch=\$3"
}

read_version_file() {
	[ -f "${version_file}" ] || fail "VERSION file not found; add VERSION in the repo root"
	version=$(read_trimmed_file "${version_file}")
	parse_semver_into current "${version}" || fail "VERSION contains invalid semver: '${version}'"
	CURRENT_VERSION=${version}
}

ensure_origin_master_ref() {
	if [ -n "${CI:-}" ] || ! git -C "${repo_root}" rev-parse --verify origin/master >/dev/null 2>&1; then
		git -C "${repo_root}" fetch --no-tags --depth=1 origin \
			'+refs/heads/master:refs/remotes/origin/master' >/dev/null 2>&1 || true
	fi
	git -C "${repo_root}" rev-parse --verify origin/master >/dev/null 2>&1
}

load_base_version() {
	HAS_BASE_VERSION=0
	if ! ensure_origin_master_ref; then
		return 0
	fi
	if ! git -C "${repo_root}" cat-file -e origin/master:VERSION 2>/dev/null; then
		return 0
	fi
	base_version=$(git -C "${repo_root}" show origin/master:VERSION | tr -d '\n')
	parse_semver_into base "${base_version}" || fail "origin/master VERSION contains invalid semver: '${base_version}'"
	BASE_VERSION=${base_version}
	HAS_BASE_VERSION=1
}

next_patch_version() {
	base_major_value=${base_major:?}
	base_minor_value=${base_minor:?}
	base_patch_value=${base_patch:?}
	printf '%s.%s.%s\n' "${base_major_value}" "${base_minor_value}" "$((base_patch_value + 1))"
}

next_minor_version() {
	base_major_value=${base_major:?}
	base_minor_value=${base_minor:?}
	printf '%s.%s.0\n' "${base_major_value}" "$((base_minor_value + 1))"
}

next_major_version() {
	base_major_value=${base_major:?}
	printf '%s.0.0\n' "$((base_major_value + 1))"
}

expected_versions() {
	printf '%s, %s, or %s' "$(next_patch_version)" "$(next_minor_version)" "$(next_major_version)"
}

current_is_behind_or_equal_base() {
	current_major_value=${current_major:?}
	current_minor_value=${current_minor:?}
	current_patch_value=${current_patch:?}
	base_major_value=${base_major:?}
	base_minor_value=${base_minor:?}
	base_patch_value=${base_patch:?}
	if [ "${current_major_value}" -lt "${base_major_value}" ]; then
		return 0
	fi
	if [ "${current_major_value}" -gt "${base_major_value}" ]; then
		return 1
	fi
	if [ "${current_minor_value}" -lt "${base_minor_value}" ]; then
		return 0
	fi
	if [ "${current_minor_value}" -gt "${base_minor_value}" ]; then
		return 1
	fi
	[ "${current_patch_value}" -le "${base_patch_value}" ]
}

write_version() {
	target=$1
	parse_semver_into current "${target}" || fail "refusing to write invalid semver: '${target}'"
	printf '%s\n' "${target}" >"${version_file}"
	log "updated VERSION to ${target}"
}

lint_or_fix() {
	read_version_file
	load_base_version

	if [ "${HAS_BASE_VERSION}" -eq 0 ]; then
		log "origin/master has no VERSION yet; treating this as the bootstrap commit"
		return 0
	fi

	if [ "${CURRENT_VERSION}" = "$(next_patch_version)" ] ||
		[ "${CURRENT_VERSION}" = "$(next_minor_version)" ] ||
		[ "${CURRENT_VERSION}" = "$(next_major_version)" ]; then
		log "VERSION ${CURRENT_VERSION} is a valid bump from origin/master (${BASE_VERSION})"
		return 0
	fi

	message="invalid version bump: ${BASE_VERSION} -> ${CURRENT_VERSION}; expected $(expected_versions)"
	if [ "${CURRENT_VERSION}" = "${BASE_VERSION}" ]; then
		message="VERSION ${CURRENT_VERSION} was not bumped (still matches origin/master); expected $(expected_versions)"
	fi

	if [ -n "${CI:-}" ]; then
		fail "${message}"
	fi

	if current_is_behind_or_equal_base; then
		write_version "$(next_patch_version)"
		return 0
	fi

	fail "${message}"
}

bump_from_base() {
	mode=$1
	read_version_file
	load_base_version
	if [ "${HAS_BASE_VERSION}" -eq 0 ]; then
		parse_semver_into base "${CURRENT_VERSION}" || fail "VERSION contains invalid semver: '${CURRENT_VERSION}'"
		BASE_VERSION=${CURRENT_VERSION}
	fi
	case "${mode}" in
	patch) write_version "$(next_patch_version)" ;;
	minor) write_version "$(next_minor_version)" ;;
	major) write_version "$(next_major_version)" ;;
	esac
}

set_version() {
	[ "$#" -eq 1 ] || fail "usage: bump-version.sh set VERSION"
	write_version "$1"
}

usage() {
	cat <<'EOF' >&2
Usage:
  bump-version.sh
  bump-version.sh lint
  bump-version.sh patch
  bump-version.sh minor
  bump-version.sh major
  bump-version.sh set VERSION

With CI=1, the default mode is lint-only.
Without CI, the default mode auto-fixes stale VERSION bumps to the next patch.
EOF
	exit 1
}

cd "${repo_root}"

case "${1:-}" in
"") lint_or_fix ;;
lint)
	shift
	[ "$#" -eq 0 ] || usage
	lint_or_fix
	;;
patch | minor | major)
	[ "$#" -eq 1 ] || usage
	bump_from_base "$1"
	;;
set)
	shift
	set_version "$@"
	;;
-h | --help) usage ;;
*) usage ;;
esac

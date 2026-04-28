#!/usr/bin/env sh
# shellcheck disable=SC2034

set -eu

test_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

fail_test() {
	printf 'test failure: %s\n' "$*" >&2
	exit 1
}

assert_eq() {
	actual=$1
	expected=$2
	[ "${actual}" = "${expected}" ] || fail_test "expected '${expected}', got '${actual}'"
}

assert_file_exists() {
	[ -e "$1" ] || fail_test "expected file to exist: $1"
}

assert_file_contains() {
	needle=$1
	path=$2
	grep -Fq "${needle}" "${path}" || fail_test "expected '${path}' to contain '${needle}'"
}

assert_symlink_target() {
	actual=$(readlink "$1")
	assert_eq "${actual}" "$2"
}

make_temp_dir() {
	tmp_parent=${TMPDIR:-/tmp}
	tmp_parent=${tmp_parent%/}
	mktemp -d "${tmp_parent}/dotfiles-test.XXXXXX"
}

cleanup_temp_dir() {
	rm -rf -- "$1"
}

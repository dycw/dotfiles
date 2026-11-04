#!/bin/sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

command -v node >/dev/null 2>&1 || fail_test 'Node.js is required to test the Safari extension'
node --test "${test_root}/tests/safari-extension.test.js"

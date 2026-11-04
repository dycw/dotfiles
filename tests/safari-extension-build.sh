#!/bin/sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

script="${test_root}/scripts/build-safari-extension.sh"
tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM
fake_bin="${tmp}/fake bin"
mkdir -p "${fake_bin}"

cat >"${fake_bin}/uname" <<'EOF'
#!/bin/sh
printf '%s\n' "${TEST_UNAME:-Darwin}"
EOF
chmod +x "${fake_bin}/uname"

cat >"${fake_bin}/xcrun" <<'EOF'
#!/bin/sh
if [ "${1:-}" = --find ]; then
	[ "${XCRUN_FIND_FAIL:-0}" -eq 0 ] || exit 1
	printf '%s\n' /fake/safari-web-extension-converter
	exit 0
fi
[ "${1:-}" = safari-web-extension-converter ] || exit 64
shift
printf '%s\n' "$@" >"${XCRUN_ARGS_LOG}"
project_location=''
while [ "$#" -gt 0 ]; do
	if [ "$1" = --project-location ]; then
		shift
		project_location=$1
		break
	fi
	shift
done
[ -n "${project_location}" ] || exit 65
mkdir -p -- "${project_location}/Safari Tab Organizer.xcodeproj"
printf '%s\n' generated >"${project_location}/Safari Tab Organizer.xcodeproj/project.pbxproj"
exit "${XCRUN_CONVERTER_STATUS:-0}"
EOF
chmod +x "${fake_bin}/xcrun"

output_project="${tmp}/Applications/Safari Tab Organizer"
args_log="${tmp}/converter args.log"

if TEST_UNAME=Linux PATH="${fake_bin}:${PATH}" HOME="${tmp}/home" \
	SAFARI_EXTENSION_PROJECT="${output_project}" XCRUN_ARGS_LOG="${args_log}" \
	/bin/bash "${script}" 2>"${tmp}/unsupported.log"; then
	fail_test 'build script should reject non-macOS systems'
else
	unsupported_status=$?
fi
assert_eq "${unsupported_status}" '1'
assert_file_contains 'only be converted on macOS' "${tmp}/unsupported.log"
[ ! -e "${output_project}" ] || fail_test 'unsupported-platform check created output'

no_xcrun_bin="${tmp}/without xcrun"
mkdir -p "${no_xcrun_bin}"
cp "${fake_bin}/uname" "${no_xcrun_bin}/uname"
if TEST_UNAME=Darwin PATH="${no_xcrun_bin}" HOME="${tmp}/home" \
	SAFARI_EXTENSION_PROJECT="${output_project}" /bin/bash "${script}" 2>"${tmp}/missing-xcrun.log"; then
	fail_test 'build script should require xcrun'
else
	missing_xcrun_status=$?
fi
assert_eq "${missing_xcrun_status}" '1'
assert_file_contains 'Install Xcode' "${tmp}/missing-xcrun.log"

if TEST_UNAME=Darwin PATH="${fake_bin}:${PATH}" HOME="${tmp}/home" \
	SAFARI_EXTENSION_PROJECT="${output_project}" XCRUN_FIND_FAIL=1 \
	XCRUN_ARGS_LOG="${args_log}" /bin/bash "${script}" 2>"${tmp}/missing-converter.log"; then
	fail_test 'build script should require the Safari converter'
else
	missing_converter_status=$?
fi
assert_eq "${missing_converter_status}" '1'
assert_file_contains 'safari-web-extension-converter is unavailable' "${tmp}/missing-converter.log"

existing_project="${tmp}/existing project"
mkdir -p "${existing_project}"
printf '%s\n' preserve >"${existing_project}/keep.txt"
: >"${args_log}"
if TEST_UNAME=Darwin PATH="${fake_bin}:${PATH}" HOME="${tmp}/home" \
	SAFARI_EXTENSION_PROJECT="${existing_project}" XCRUN_ARGS_LOG="${args_log}" \
	/bin/bash "${script}" 2>"${tmp}/existing-project.log"; then
	fail_test 'build script should refuse an existing project'
else
	existing_project_status=$?
fi
assert_eq "${existing_project_status}" '1'
assert_file_contains 'Refusing to overwrite existing project' "${tmp}/existing-project.log"
assert_file_exists "${existing_project}/keep.txt"
[ ! -s "${args_log}" ] || fail_test 'converter ran despite existing output'

failed_project="${tmp}/failed project"
if TEST_UNAME=Darwin PATH="${fake_bin}:${PATH}" HOME="${tmp}/home" \
	SAFARI_EXTENSION_PROJECT="${failed_project}" XCRUN_ARGS_LOG="${args_log}" \
	XCRUN_CONVERTER_STATUS=19 /bin/bash "${script}" 2>"${tmp}/converter-failure.log"; then
	fail_test 'build script should report a converter failure'
else
	converter_status=$?
fi
assert_eq "${converter_status}" '19'
assert_file_contains 'Safari Web Extension conversion failed' "${tmp}/converter-failure.log"
[ ! -e "${failed_project}" ] || fail_test 'failed conversion left a partial installed project'
staged_project=$(sed -n '3p' "${args_log}")
[ ! -e "${staged_project}" ] || fail_test 'failed conversion left its staging project'

success_project="${tmp}/output with spaces/Safari Tab Organizer"
TEST_UNAME=Darwin PATH="${fake_bin}:${PATH}" HOME="${tmp}/home" \
	SAFARI_EXTENSION_PROJECT="${success_project}" XCRUN_ARGS_LOG="${args_log}" \
	/bin/bash "${script}" >"${tmp}/success.log"
assert_file_exists "${success_project}/Safari Tab Organizer.xcodeproj/project.pbxproj"
assert_file_contains "${test_root}/configs/safari/extension" "${args_log}"
assert_file_contains 'project-location' "${args_log}"
assert_file_contains 'Safari Tab Organizer' "${args_log}"
assert_file_contains 'com.dotfilesderek.safari-tab-organizer' "${args_log}"
assert_file_contains "Generated Safari Tab Organizer at ${success_project}" "${tmp}/success.log"

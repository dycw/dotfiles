#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

script_dir="${tmp}/dotfiles/restic"
bin="${tmp}/bin"
RESTIC_LOG="${tmp}/restic.log"
mkdir -p "${script_dir}" "${bin}"
cp -- "${test_root}/restic/snapshots" "${script_dir}/snapshots"
cat >"${script_dir}/.env" <<'EOF'
export RESTIC_SNAPSHOTS_TEST=loaded
EOF

cat >"${bin}/restic" <<'EOF'
#!/bin/sh
[ "${1:-}" = snapshots ] || exit 2
shift
printf '%s' "${RESTIC_SNAPSHOTS_TEST:-missing}" >>"${RESTIC_LOG}"
for argument in "$@"; do printf '|%s' "${argument}" >>"${RESTIC_LOG}"; done
printf '\n' >>"${RESTIC_LOG}"
EOF
chmod +x "${bin}/restic"

export RESTIC_LOG
PATH="${bin}:${PATH}"
export PATH
sh "${script_dir}/snapshots" --latest 4
assert_file_contains 'loaded|--latest|4' "${RESTIC_LOG}"

rm -- "${script_dir}/.env"
if sh "${script_dir}/snapshots" >"${tmp}/missing-env.log" 2>&1; then
	fail_test 'snapshots should fail when its environment file is missing'
fi
assert_file_contains 'Unable to find environment file' "${tmp}/missing-env.log"

#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2154

[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

bin_dir="${tmp}/bin"
mkdir -p "${bin_dir}"

versions_file="${tmp}/versions"
deleted_file="${tmp}/deleted"
output_file="${tmp}/output"
cat >"${versions_file}" <<'EOF'
0.7.11
0.7.10
0.7.9
0.7.8
0.7.6
0.7.5
0.7.4
0.7.3
0.7.2
EOF
: >"${deleted_file}"

cat >"${bin_dir}/curl" <<'EOF'
#!/usr/bin/env bash
set -eu

if [ "${1:-}" = "-s" ]; then
	url=${@: -1}
	version=${url##*/}
	printf '%s\n' "${version}" >>"${DELETED_FILE}"
	tmp="${VERSIONS_FILE}.tmp"
	grep -Fvx -- "${version}" "${VERSIONS_FILE}" >"${tmp}" || true
	mv "${tmp}" "${VERSIONS_FILE}"
	printf '204'
	exit 0
fi

printf '['
sep=''
count=0
while IFS= read -r version && [ "${count}" -lt 5 ]; do
	printf '%s{"version":"%s"}' "${sep}" "${version}"
	sep=','
	count=$((count + 1))
done <"${VERSIONS_FILE}"
printf ']'
EOF
chmod +x "${bin_dir}/curl"

PATH="${bin_dir}:${PATH}"
TOKEN=test-token
VERSIONS_FILE=${versions_file}
DELETED_FILE=${deleted_file}
export PATH TOKEN VERSIONS_FILE DELETED_FILE

. "${test_root}/configs/bash/bashrc.d/gitea.sh"

printf 'y\n' | gitea_pkg_purge 'https://gitea.ai/derek/-/packages/cargo/dotfiles' >"${output_file}"

assert_eq "$(cat "${versions_file}")" ''
assert_eq "$(cat "${deleted_file}")" "$(
	cat <<'EOF'
0.7.11
0.7.10
0.7.9
0.7.8
0.7.6
0.7.5
0.7.4
0.7.3
0.7.2
EOF
)"
assert_file_contains 'deleted 9 versions' "${output_file}"

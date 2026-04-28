#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

entrypoint="${test_root}/setup.sh"

local_repo="${tmp}/local-repo"
local_home="${tmp}/local-home"
local_bin="${tmp}/local-bin"
local_log="${tmp}/local.log"
mkdir -p "${local_repo}/scripts/_setup" "${local_repo}/.git" "${local_home}" "${local_bin}"
local_repo=$(CDPATH='' cd -- "${local_repo}" && pwd -P)
cp "${entrypoint}" "${local_repo}/setup.sh"

cat >"${local_repo}/scripts/_setup/install.sh" <<EOF
#!/bin/sh
printf 'install\n' >>"${local_log}"
EOF
cat >"${local_repo}/scripts/_setup/setup.sh" <<EOF
#!/bin/sh
printf 'setup\n' >>"${local_log}"
EOF
chmod +x "${local_repo}/scripts/_setup/install.sh" "${local_repo}/scripts/_setup/setup.sh"

cat >"${local_bin}/git" <<EOF
#!/bin/sh
printf 'git %s\n' "\$*" >>"${local_log}"
exit 0
EOF
chmod +x "${local_bin}/git"

cat >"${local_bin}/sudo" <<'EOF'
#!/bin/sh
while [ $# -gt 0 ]; do
	case "$1" in
	-*) shift ;;
	*) break ;;
	esac
done
[ $# -gt 0 ] && exec "$@"
exit 0
EOF
chmod +x "${local_bin}/sudo"

PATH="${local_bin}:${PATH}" HOME="${local_home}" sh "${local_repo}/setup.sh"

assert_file_contains "git -C ${local_repo} fetch origin" "${local_log}"
assert_file_contains "git -C ${local_repo} reset --hard origin/master" "${local_log}"
assert_file_contains 'install' "${local_log}"
assert_file_contains 'setup' "${local_log}"

bootstrap_dir="${tmp}/bootstrap"
bootstrap_home="${tmp}/bootstrap-home"
bootstrap_bin="${tmp}/bootstrap-bin"
bootstrap_log="${tmp}/bootstrap.log"
mkdir -p "${bootstrap_dir}" "${bootstrap_home}" "${bootstrap_bin}"
cp "${entrypoint}" "${bootstrap_dir}/setup.sh"

cat >"${bootstrap_bin}/git" <<EOF
#!/bin/sh
printf 'git %s\n' "\$*" >>"${bootstrap_log}"
if [ "\$1" = clone ]; then
	target=\$4
	mkdir -p "\${target}/scripts/_setup" "\${target}/.git"
	cat >"\${target}/scripts/_setup/install.sh" <<'EOI'
#!/bin/sh
printf 'install\n' >>"${bootstrap_log}"
EOI
	cat >"\${target}/scripts/_setup/setup.sh" <<'EOS'
#!/bin/sh
printf 'setup\n' >>"${bootstrap_log}"
EOS
	chmod +x "\${target}/scripts/_setup/install.sh" "\${target}/scripts/_setup/setup.sh"
fi
exit 0
EOF
chmod +x "${bootstrap_bin}/git"

cat >"${bootstrap_bin}/sudo" <<'EOF'
#!/bin/sh
while [ $# -gt 0 ]; do
	case "$1" in
	-*) shift ;;
	*) break ;;
	esac
done
[ $# -gt 0 ] && exec "$@"
exit 0
EOF
chmod +x "${bootstrap_bin}/sudo"

DOTFILES_REPO="https://github.com/dycw/dotfiles.git" \
	PATH="${bootstrap_bin}:${PATH}" HOME="${bootstrap_home}" \
	sh "${bootstrap_dir}/setup.sh"

assert_file_contains "git clone --recurse-submodules https://github.com/dycw/dotfiles.git ${bootstrap_home}/dotfiles" "${bootstrap_log}"
assert_file_contains 'install' "${bootstrap_log}"
assert_file_contains 'setup' "${bootstrap_log}"

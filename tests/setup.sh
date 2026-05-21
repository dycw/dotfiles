#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

entrypoint="${test_root}/setup.sh"

#### local-repo case: running setup.sh from inside the dotfiles dir ###########

local_repo="${tmp}/local-repo"
local_home="${tmp}/local-home"
local_bin="${tmp}/local-bin"
local_log="${tmp}/local.log"
mkdir -p "${local_repo}/configs" "${local_repo}/.git" "${local_home}" "${local_bin}"
local_repo=$(CDPATH='' cd -- "${local_repo}" && pwd -P)
cp "${entrypoint}" "${local_repo}/setup.sh"

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

# Wrapper lives inside local_repo so that $0-based self_dir resolution finds .git
cat >"${local_repo}/run-test.sh" <<EOF
#!/bin/sh
_SETUP_MAIN=0 . '${local_repo}/setup.sh'
install_all() { printf 'install_all\n' >>'${local_log}'; }
setup_all() { printf 'setup_all\n' >>'${local_log}'; }
determine_platform() { platform=linux; }
run_local_self
EOF
chmod +x "${local_repo}/run-test.sh"

PATH="${local_bin}:${PATH}" HOME="${local_home}" sh "${local_repo}/run-test.sh"

assert_file_contains "git -C ${local_repo} fetch origin" "${local_log}"
assert_file_contains "git -C ${local_repo} reset --hard origin/master" "${local_log}"
assert_file_contains 'install_all' "${local_log}"
assert_file_contains 'setup_all' "${local_log}"

#### bootstrap case: running setup.sh from outside the dotfiles dir ###########

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
	target=\$3
	mkdir -p "\${target}/configs" "\${target}/.git"
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

# Wrapper lives outside any .git dir so resolve_dotfiles falls back to clone
cat >"${bootstrap_dir}/run-test.sh" <<EOF
#!/bin/sh
_SETUP_MAIN=0 . '${bootstrap_dir}/setup.sh'
install_all() { printf 'install_all\n' >>'${bootstrap_log}'; }
setup_all() { printf 'setup_all\n' >>'${bootstrap_log}'; }
determine_platform() { platform=linux; }
run_local_self
EOF
chmod +x "${bootstrap_dir}/run-test.sh"

PATH="${bootstrap_bin}:${PATH}" HOME="${bootstrap_home}" sh "${bootstrap_dir}/run-test.sh"

assert_file_contains "git clone https://github.com/dycw/dotfiles.git ${bootstrap_home}/dotfiles" "${bootstrap_log}"
assert_file_contains 'install_all' "${bootstrap_log}"
assert_file_contains 'setup_all' "${bootstrap_log}"

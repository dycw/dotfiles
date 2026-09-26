#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

entrypoint="${test_root}/setup.sh"

#### local-repo case: running setup.sh from inside the dotfiles dir ###########

local_repo="${tmp}/local repo"
local_home="${tmp}/local home"
local_bin="${tmp}/local bin"
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
id() { if [ "\$1" = -u ]; then printf '1000\\n'; else command id "\$@"; fi; }
install_all() { printf 'install_all\n' >>'${local_log}'; }
setup_all() { printf 'setup_all\n' >>'${local_log}'; }
determine_platform() { platform=linux; }
run_local_self
run_local_self
EOF
chmod +x "${local_repo}/run-test.sh"

PATH="${local_bin}:${PATH}" HOME="${local_home}" sh "${local_repo}/run-test.sh"

assert_eq "$(grep -Fc "git -C ${local_repo} fetch origin" "${local_log}")" '2'
assert_eq "$(grep -Fc "git -C ${local_repo} reset --hard origin/master" "${local_log}")" '2'
assert_eq "$(grep -Fc 'install_all' "${local_log}")" '2'
assert_eq "$(grep -Fc 'setup_all' "${local_log}")" '2'

#### bootstrap case: running setup.sh from outside the dotfiles dir ###########

bootstrap_dir="${tmp}/bootstrap"
bootstrap_home="${tmp}/bootstrap home"
bootstrap_bin="${tmp}/bootstrap-bin"
bootstrap_log="${tmp}/bootstrap.log"
mkdir -p "${bootstrap_dir}" "${bootstrap_home}" "${bootstrap_bin}"
cp "${entrypoint}" "${bootstrap_dir}/setup.sh"

cat >"${bootstrap_bin}/git" <<EOF
#!/bin/sh
printf 'git %s\n' "\$*" >>"${bootstrap_log}"
if [ "\$1" = clone ]; then
	target=\$3
	if [ ! -e "${bootstrap_log}.clone-failed" ]; then
		: >"${bootstrap_log}.clone-failed"
		mkdir -p "\${target}/.git"
		exit 1
	fi
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
id() { if [ "\$1" = -u ]; then printf '1000\\n'; else command id "\$@"; fi; }
install_all() { printf 'install_all\n' >>'${bootstrap_log}'; }
setup_all() { printf 'setup_all\n' >>'${bootstrap_log}'; }
determine_platform() { platform=linux; }
if run_local_self; then
	echo 'expected the first clone attempt to fail' >&2
	exit 1
else
	clone_status=\$?
fi
[ "\${clone_status}" -ne 0 ]
[ ! -e '${bootstrap_home}/dotfiles' ]
for candidate in '${bootstrap_home}'/dotfiles.clone.*; do
	[ ! -e "\${candidate}" ] || exit 1
done
run_local_self
run_local_self
EOF
chmod +x "${bootstrap_dir}/run-test.sh"

PATH="${bootstrap_bin}:${PATH}" HOME="${bootstrap_home}" sh "${bootstrap_dir}/run-test.sh"

assert_eq "$(grep -Fc 'git clone https://github.com/dycw/dotfiles.git ' "${bootstrap_log}")" '2'
assert_eq "$(grep -Fc "git -C ${bootstrap_home}/dotfiles fetch origin" "${bootstrap_log}")" '1'
assert_eq "$(grep -Fc "git -C ${bootstrap_home}/dotfiles reset --hard origin/master" "${bootstrap_log}")" '1'
assert_eq "$(grep -Fc 'install_all' "${bootstrap_log}")" '2'
assert_eq "$(grep -Fc 'setup_all' "${bootstrap_log}")" '2'
[ -d "${bootstrap_home}/dotfiles/.git" ]

#### installer and package provisioning tests ###############################

run_setup_install_tests() (
	set -eu
	tmp=$(make_temp_dir)
	trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

	HOME="${tmp}/test home"
	XDG_CONFIG_HOME="${tmp}/test config"
	XDG_CACHE_HOME="${tmp}/test cache"
	TMPDIR="${tmp}/temp files"
	mkdir -p "${HOME}" "${XDG_CONFIG_HOME}" "${TMPDIR}"
	export HOME XDG_CONFIG_HOME XDG_CACHE_HOME TMPDIR

	_SETUP_MAIN=0 . "${test_root}/setup.sh"
	configs="${test_root}/configs"
	run_root() {
		if [ "$1" = apt-get ]; then
			shift
			apt_get "$@"
		else
			"$@"
		fi
	}

	#### apt and brew package checks converge on rerun ############################

	APT_LOG="${tmp}/apt.log"
	DPKG_INSTALLED='curl'
	dpkg() {
		case " ${DPKG_INSTALLED} " in
		*" $2 "*) return 0 ;;
		*) return 1 ;;
		esac
	}
	apt_get() {
		printf '%s\n' "$*" >>"${APT_LOG}"
		[ "${APT_FAIL:-0}" -eq 0 ] || return 23
		for package in "$@"; do
			case "${package}" in
			curl | rsync | sudo | xclip | xsel)
				case " ${DPKG_INSTALLED} " in
				*" ${package} "*) ;;
				*) DPKG_INSTALLED="${DPKG_INSTALLED}${DPKG_INSTALLED:+ }${package}" ;;
				esac
				;;
			esac
		done
	}

	install_missing_apt_packages curl rsync
	install_missing_apt_packages curl rsync
	assert_eq "$(grep -Fc 'update' "${APT_LOG}")" '1'
	assert_eq "$(grep -Fc 'install -y --no-install-recommends rsync' "${APT_LOG}")" '1'

	APT_FAIL=1
	if install_missing_apt_packages xclip; then
		fail_test 'apt package installation should preserve a child failure'
	else
		apt_status=$?
	fi
	assert_eq "${apt_status}" '23'
	APT_FAIL=0
	install_linux_packages
	assert_file_contains 'build-essential' "${APT_LOG}"

	BREW_LOG="${tmp}/brew.log"
	BREW_FORMULAE='present'
	BREW_CASKS='present-cask'
	brew() {
		operation=$1
		shift
		case "${operation}" in
		list)
			case "$1" in
			--formula) printf '%s\n' "${BREW_FORMULAE}" ;;
			--cask) printf '%s\n' "${BREW_CASKS}" ;;
			*) return 2 ;;
			esac
			;;
		install)
			printf 'install %s\n' "$*" >>"${BREW_LOG}"
			[ "${BREW_FAIL:-0}" -eq 0 ] || return 24
			if [ "${1:-}" = --cask ]; then
				shift 2
				for item in "$@"; do
					BREW_CASKS=$(printf '%s\n%s' "${BREW_CASKS}" "${item}")
				done
			else
				for item in "$@"; do
					BREW_FORMULAE=$(printf '%s\n%s' "${BREW_FORMULAE}" "${item}")
				done
			fi
			;;
		*) return 2 ;;
		esac
	}

	install_missing_brew_formulas present new-formula
	install_missing_brew_formulas present new-formula
	assert_eq "$(grep -Fc 'install new-formula' "${BREW_LOG}")" '1'
	install_missing_brew_casks present-cask new-cask
	install_missing_brew_casks present-cask new-cask
	assert_eq "$(grep -Fc 'install --cask --adopt new-cask' "${BREW_LOG}")" '1'

	BREW_FAIL=1
	if install_missing_brew_formulas failed-formula; then
		fail_test 'brew formula installation should preserve a child failure'
	else
		brew_status=$?
	fi
	assert_eq "${brew_status}" '24'
	BREW_FAIL=0

	#### Rust updates are sequential and propagate failures ########################

	assert_eq "$(rust_tool_command cargo-edit)" 'cargo-add'
	assert_eq "$(rust_tool_command bottom)" 'btm'
	assert_eq "$(rust_tool_command du-dust)" 'dust'
	assert_eq "$(rust_tool_command taplo-cli)" 'taplo'

	RUST_LOG="${tmp}/rust.log"
	export RUST_LOG
	mkdir -p "${tmp}/bin"
	cat >"${tmp}/bin/cargo-binstall" <<'EOF'
#!/bin/sh
exit 0
EOF
	chmod +x "${tmp}/bin/cargo-binstall"
	PATH="${tmp}/bin:${PATH}"
	export PATH
	rustup() {
		printf 'rustup %s\n' "$*" >>"${RUST_LOG}"
	}
	cargo() {
		printf 'cargo %s\n' "$*" >>"${RUST_LOG}"
		[ "${4:-}" != "${FAIL_RUST_TOOL:-}" ] || return 25
	}
	should_upgrade=1
	FAIL_RUST_TOOL=cargo-edit
	if maybe_upgrade_rust; then
		fail_test 'Rust tool update should preserve a child failure'
	else
		rust_status=$?
	fi
	assert_eq "${rust_status}" '1'
	assert_file_contains 'cargo binstall -y --force cargo-edit' "${RUST_LOG}"
	if grep -Fq 'cargo binstall -y --force cargo-nextest' "${RUST_LOG}"; then
		fail_test 'Rust updates should stop after the first failed tool'
	fi
	install_rust_tool taplo-cli
	assert_file_contains 'cargo install --locked taplo-cli' "${RUST_LOG}"
	if grep -Fq 'cargo binstall -y taplo-cli' "${RUST_LOG}"; then
		fail_test 'taplo-cli should use its working source-install path directly'
	fi

	#### downloaded installers report failures and clean temporary files ##########

	CURL_LOG="${tmp}/curl.log"
	SCRIPT_LOG="${tmp}/installer.log"
	CURL_SCRIPT_EXIT=0
	CURL_FAIL=0
	CURL_ARCHIVE=0
	export CURL_LOG SCRIPT_LOG CURL_SCRIPT_EXIT CURL_FAIL CURL_ARCHIVE
	curl() {
		printf '%s\n' "$*" >>"${CURL_LOG}"
		[ "${CURL_FAIL}" -eq 0 ] || return 22
		output=''
		while [ "$#" -gt 0 ]; do
			case "$1" in
			-o)
				output=$2
				shift 2
				;;
			*) shift ;;
			esac
		done
		[ -n "${output}" ] || return 2
		if [ "${CURL_ARCHIVE}" -eq 1 ]; then
			cp -- "${KEYMAPP_ARCHIVE}" "${output}"
		else
			cat >"${output}" <<'INSTALLER'
printf '%s\n' ran >>"${SCRIPT_LOG}"
exit "${CURL_SCRIPT_EXIT}"
INSTALLER
		fi
	}

	run_script_from_url https://example.invalid/installer.sh /bin/sh -s
	assert_file_contains 'ran' "${SCRIPT_LOG}"
	CURL_SCRIPT_EXIT=7
	if run_script_from_url https://example.invalid/installer.sh /bin/sh -s; then
		fail_test 'downloaded installer failure should be returned'
	else
		installer_status=$?
	fi
	assert_eq "${installer_status}" '7'
	CURL_SCRIPT_EXIT=0
	CURL_FAIL=1
	if run_script_from_url https://example.invalid/installer.sh /bin/sh -s 2>"${tmp}/curl-error.log"; then
		fail_test 'download failure should be returned'
	else
		curl_status=$?
	fi
	assert_eq "${curl_status}" '1'
	CURL_FAIL=0
	for leftover in "${TMPDIR}"/dotfiles-installer.*; do
		[ ! -e "${leftover}" ] || fail_test "installer temp file leaked: ${leftover}"
	done

	#### Node.js baseline is enforced without reinstalling a supported version ######

	NODE_VERSION=20.19.2
	export NODE_VERSION
	cat >"${tmp}/bin/npm" <<'EOF'
#!/bin/sh
exit 0
EOF
	cat >"${tmp}/bin/sudo" <<'EOF'
#!/bin/sh
[ "${1:-}" != -E ] || shift
exec "$@"
EOF
	chmod +x "${tmp}/bin/npm" "${tmp}/bin/sudo"
	node() { printf 'v%s\n' "${NODE_VERSION}"; }
	acquire_sudo() { :; }
	ensure_nodejs_22
	NODE_VERSION=22.22.2
	ensure_nodejs_22
	assert_eq "$(grep -Fc 'https://deb.nodesource.com/setup_22.x' "${CURL_LOG}")" '1'
	assert_eq "$(grep -Fc 'install -y --no-install-recommends nodejs' "${APT_LOG}")" '1'

	#### remote bootstrap uses one connection and cleans up ########################

	REMOTE_TMPDIR="${tmp}/remote temp files"
	REMOTE_LOG="${tmp}/remote.log"
	remote_source="${tmp}/remote setup.sh"
	mkdir -p "${REMOTE_TMPDIR}"
	cat >"${remote_source}" <<'EOF'
#!/bin/sh
printf remote-ran >>"${REMOTE_LOG}"
EOF
	chmod +x "${remote_source}"
	export REMOTE_LOG
	original_self_path=${self_path}
	original_tmpdir=${TMPDIR}
	self_path=${remote_source}
	TMPDIR=${REMOTE_TMPDIR}
	export TMPDIR
	SSH_CALLS=0
	ssh() {
		SSH_CALLS=$((SSH_CALLS + 1))
		[ "$#" -eq 4 ] && [ "$1" = -p ] && [ "$2" = 222 ] && [ "$3" = nonroot@localhost ] || return 2
		/bin/sh -c "$4"
	}
	run_remote nonroot@localhost 222
	assert_eq "${SSH_CALLS}" '1'
	assert_file_contains 'remote-ran' "${REMOTE_LOG}"
	for leftover in "${REMOTE_TMPDIR}"/setup.*; do
		[ ! -e "${leftover}" ] || fail_test "remote setup temp file leaked: ${leftover}"
	done
	self_path=${original_self_path}
	TMPDIR=${original_tmpdir}
	export TMPDIR

	#### keymapp retries are safe and completed installs are reused ###############

	KEYMAPP_HOME="${tmp}/keymapp home"
	mkdir -p "${KEYMAPP_HOME}/.local/bin"
	HOME=${KEYMAPP_HOME}
	export HOME
	keymapp_bin="${HOME}/.local/bin/keymapp"
	printf '#!/bin/sh\nprintf old\n' >"${keymapp_bin}"
	chmod +x "${keymapp_bin}"
	should_upgrade=0
	curl_calls=$(wc -l <"${CURL_LOG}" | tr -d ' ')
	CURL_FAIL=1
	install_keymapp
	assert_eq "$(wc -l <"${CURL_LOG}" | tr -d ' ')" "${curl_calls}"

	KEYMAPP_ARCHIVE="${tmp}/keymapp.tar.gz"
	cat >"${tmp}/keymapp" <<'EOF'
#!/bin/sh
printf 'new keymapp\n'
EOF
	chmod +x "${tmp}/keymapp"
	tar -czf "${KEYMAPP_ARCHIVE}" -C "${tmp}" keymapp
	export KEYMAPP_ARCHIVE
	CURL_FAIL=0
	CURL_ARCHIVE=1
	should_upgrade=1
	install_keymapp
	assert_file_contains 'new keymapp' "${keymapp_bin}"
	CURL_FAIL=1
	if install_keymapp 2>/dev/null; then
		fail_test 'a failed keymapp refresh should be reported'
	fi
	assert_file_contains 'new keymapp' "${keymapp_bin}"
	for leftover in "${TMPDIR}"/dotfiles-keymapp.*; do
		[ ! -e "${leftover}" ] || fail_test "keymapp temp directory leaked: ${leftover}"
	done

	#### Docker group membership is applied once even on rerun ###################

	DOCKER_GROUP_ADDED=0
	USER=setup-test
	export USER
	id() {
		if [ "${1:-}" = -nG ]; then
			if [ "${DOCKER_GROUP_ADDED}" -eq 1 ]; then
				printf '%s docker\n' "$2"
			else
				printf '%s\n' "$2"
			fi
		else
			command id "$@"
		fi
	}
	# Invoked indirectly by the sourced install_docker_linux operation.
	# shellcheck disable=SC2317,SC2329
	usermod() {
		printf '%s\n' "$*" >>"${tmp}/usermod.log"
		DOCKER_GROUP_ADDED=1
	}
	printf '#!/bin/sh\nexit 0\n' >"${tmp}/bin/docker"
	chmod +x "${tmp}/bin/docker"
	PATH="${tmp}/bin:${PATH}"
	export PATH
	install_docker_linux
	install_docker_linux
	assert_eq "$(grep -Fc -- '-aG docker setup-test' "${tmp}/usermod.log")" '1'

	#### Linux user tools are installed once and reused on rerun ##################

	TOOL_HOME="${tmp}/Linux tool home"
	TOOL_BIN="${tmp}/tool bin"
	TOOL_LOG="${tmp}/tool-install.log"
	mkdir -p "${TOOL_HOME}" "${TOOL_BIN}"
	HOME=${TOOL_HOME}
	export HOME TOOL_LOG
	cat >"${TOOL_BIN}/pipx" <<'EOF'
#!/bin/sh
printf 'pipx %s\n' "$*" >>"${TOOL_LOG}"
mkdir -p "${HOME}/.local/bin"
printf '#!/bin/sh\nexit 0\n' >"${HOME}/.local/bin/$3"
chmod +x "${HOME}/.local/bin/$3"
EOF
	cat >"${TOOL_BIN}/npm" <<'EOF'
#!/bin/sh
printf 'npm %s\n' "$*" >>"${TOOL_LOG}"
prefix=''
while [ "$#" -gt 0 ]; do
	case "$1" in
	--prefix)
		prefix=$2
		shift 2
		;;
	*) shift ;;
	esac
done
mkdir -p "${prefix}/bin"
printf '#!/bin/sh\nexit 0\n' >"${prefix}/bin/markdownlint"
printf '#!/bin/sh\nexit 0\n' >"${prefix}/bin/prettier"
chmod +x "${prefix}/bin/markdownlint" "${prefix}/bin/prettier"
EOF
	chmod +x "${TOOL_BIN}/pipx" "${TOOL_BIN}/npm"
	PATH="${TOOL_BIN}:${PATH}"
	export PATH
	should_upgrade=1
	install_linux_user_tools
	should_upgrade=0
	install_linux_user_tools
	assert_eq "$(grep -Fc 'pipx install --force ruff' "${TOOL_LOG}")" '1'
	assert_eq "$(grep -Fc 'pipx install --force uv' "${TOOL_LOG}")" '1'
	assert_eq "$(grep -Fc 'npm install --global' "${TOOL_LOG}")" '1'

	#### failed installation does not mark upgrades complete ######################

	INSTALL_STUBS="${tmp}/install-stubs.sh"
	cat >"${INSTALL_STUBS}" <<'EOF'
record_install_call() { printf '%s\n' "$1" >>"${INSTALL_LOG}"; }
ensure_brew() { record_install_call ensure_brew; }
remove_unwanted_brew_formulas() { record_install_call remove_unwanted_brew_formulas; }
install_common_brew_formulas() { record_install_call install_common_brew_formulas; }
maybe_upgrade_brew_formulas() { if [ "${should_upgrade}" -eq 1 ]; then record_install_call maybe_upgrade_brew_formulas; fi; }
maybe_upgrade_rust() { if [ "${should_upgrade}" -eq 1 ]; then record_install_call maybe_upgrade_rust; fi; }
install_rust_tools() { record_install_call install_rust_tools; }
install_linux_packages() {
	record_install_call install_linux_packages
	[ "${INSTALL_FAIL:-}" != apt ] || return 23
}
maybe_upgrade_apt_packages() { if [ "${should_upgrade}" -eq 1 ]; then record_install_call maybe_upgrade_apt_packages; fi; }
ensure_nodejs_22() { record_install_call ensure_nodejs_22; }
install_linux_user_tools() { record_install_call install_linux_user_tools; }
install_tailscale_linux() { record_install_call install_tailscale_linux; }
install_docker_linux() { record_install_call install_docker_linux; }
install_keymapp() { record_install_call install_keymapp; }
EOF

	FAIL_CACHE="${tmp}/failure cache"
	INSTALL_LOG="${tmp}/failure-install.log"
	INSTALL_FAIL=apt
	export FAIL_CACHE INSTALL_LOG INSTALL_FAIL INSTALL_STUBS
	cat >"${tmp}/install-failure.sh" <<EOF
#!/bin/sh
set -eu
HOME='${tmp}/failure home'
XDG_CONFIG_HOME='${tmp}/failure config'
XDG_CACHE_HOME='${FAIL_CACHE}'
INSTALL_LOG='${INSTALL_LOG}'
INSTALL_FAIL=apt
export HOME XDG_CONFIG_HOME XDG_CACHE_HOME INSTALL_LOG INSTALL_FAIL
_SETUP_MAIN=0 . '${test_root}/setup.sh'
platform=linux
. '${INSTALL_STUBS}'
install_all
EOF
	if sh "${tmp}/install-failure.sh" >"${tmp}/install-failure.out" 2>&1; then
		fail_test 'install_all should fail when a required package stage fails'
	fi
	[ ! -e "${FAIL_CACHE}/dotfiles/updated" ] || fail_test 'failed setup was incorrectly marked upgraded'

	SUCCESS_CACHE="${tmp}/success-cache"
	INSTALL_LOG="${tmp}/success-install.log"
	INSTALL_FAIL=''
	export SUCCESS_CACHE INSTALL_LOG INSTALL_FAIL
	HOME="${tmp}/success home"
	XDG_CONFIG_HOME="${tmp}/success config"
	XDG_CACHE_HOME=${SUCCESS_CACHE}
	export HOME XDG_CONFIG_HOME XDG_CACHE_HOME
	upgrade_timer="${XDG_CACHE_HOME}/dotfiles/updated"
	platform=linux
	. "${INSTALL_STUBS}"
	install_all
	assert_file_exists "${upgrade_timer}"
	install_all
	assert_eq "$(grep -Fc 'maybe_upgrade_rust' "${INSTALL_LOG}")" '1'
	assert_eq "$(grep -Fc 'maybe_upgrade_apt_packages' "${INSTALL_LOG}")" '1'
	assert_eq "$(grep -Fc 'ensure_nodejs_22' "${INSTALL_LOG}")" '2'
	assert_eq "$(grep -Fc 'install_linux_packages' "${INSTALL_LOG}")" '2'
	assert_eq "$(grep -Fc 'install_linux_user_tools' "${INSTALL_LOG}")" '2'
	assert_eq "$(grep -Fc 'install_tailscale_linux' "${INSTALL_LOG}")" '2'
	assert_eq "$(grep -Fc 'install_docker_linux' "${INSTALL_LOG}")" '2'
	assert_eq "$(grep -Fc 'install_keymapp' "${INSTALL_LOG}")" '2'
)

run_setup_install_tests

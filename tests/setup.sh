#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

entrypoint="${test_root}/setup.sh"

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

run_setup_install_tests() (
	set -eu
	tmp=$(make_temp_dir)
	trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

	HOME="${tmp}/test home"
	CARGO_HOME="${tmp}/cargo home"
	XDG_CONFIG_HOME="${tmp}/test config"
	XDG_CACHE_HOME="${tmp}/test cache"
	TMPDIR="${tmp}/temp files"
	mkdir -p "${HOME}" "${CARGO_HOME}" "${XDG_CONFIG_HOME}" "${TMPDIR}"
	export HOME CARGO_HOME XDG_CONFIG_HOME XDG_CACHE_HOME TMPDIR

	_SETUP_MAIN=0 . "${test_root}/setup.sh"

	(
		require_linux() { :; }
		TEST_UNAME_MACHINE=x86_64
		uname() {
			if [ "${1:-}" = -m ]; then
				printf '%s\n' "${TEST_UNAME_MACHINE}"
			else
				printf 'Linux\n'
			fi
		}
		determine_platform
		assert_eq "${platform}" 'linux'
		TEST_UNAME_MACHINE=aarch64
		if (determine_platform) 2>"${tmp}/unsupported-arch.log"; then
			fail_test 'Linux setup should reject non-x86_64 architectures'
		else
			arch_status=$?
		fi
		assert_eq "${arch_status}" '1'
		assert_file_contains "Unsupported Linux architecture 'aarch64'; only x86_64 is supported" "${tmp}/unsupported-arch.log"
	)

	RUN_ROOT_LOG="${tmp}/run-root.log"
	RUN_ROOT_UID=0
	mkdir -p "${tmp}/run-root-bin"
	cat >"${tmp}/run-root-bin/apt-get" <<'EOF'
#!/bin/sh
printf '%s|%s\n' "${DEBIAN_FRONTEND:-unset}" "$*" >>"${RUN_ROOT_LOG}"
EOF
	chmod +x "${tmp}/run-root-bin/apt-get"
	PATH="${tmp}/run-root-bin:${PATH}"
	export PATH RUN_ROOT_LOG RUN_ROOT_UID
	id() {
		if [ "${1:-}" = -u ]; then
			printf '%s\n' "${RUN_ROOT_UID}"
		else
			command id "$@"
		fi
	}
	sudo() {
		case "${1:-}" in
		-n)
			[ "${2:-}" = true ]
			;;
		env)
			shift
			command env "$@"
			;;
		-E)
			shift
			"$@"
			;;
		*) return 1 ;;
		esac
	}
	run_root apt-get install -y iperf3
	RUN_ROOT_UID=1000
	run_root apt-get install -y iperf3
	assert_eq "$(grep -Fc 'noninteractive|install -y iperf3' "${RUN_ROOT_LOG}")" '2'

	GIT_BOOTSTRAP_LOG="${tmp}/git-bootstrap.log"
	(
		platform=linux
		git() { return 1; }
		run_root() { printf '%s\n' "$*" >>"${GIT_BOOTSTRAP_LOG}"; }
		ensure_git
	) >/dev/null
	assert_file_contains 'apt-get -o DPkg::Lock::Timeout=300 update' "${GIT_BOOTSTRAP_LOG}"
	assert_file_contains 'apt-get -o DPkg::Lock::Timeout=300 install -y git' "${GIT_BOOTSTRAP_LOG}"
	: >"${GIT_BOOTSTRAP_LOG}"
	(
		platform=mac
		git() { return 1; }
		ensure_brew() { printf 'ensure_brew\n' >>"${GIT_BOOTSTRAP_LOG}"; }
		brew() { printf 'brew %s\n' "$*" >>"${GIT_BOOTSTRAP_LOG}"; }
		ensure_git
	) >/dev/null
	assert_file_contains 'ensure_brew' "${GIT_BOOTSTRAP_LOG}"
	assert_file_contains 'brew install git' "${GIT_BOOTSTRAP_LOG}"

	configs="${test_root}/configs"
	run_root() {
		if [ "$1" = apt-get ]; then
			shift
			apt_get "$@"
		else
			"$@"
		fi
	}

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
	BREW_FORMULAE_FILE="${tmp}/brew-formulae"
	printf '%s\n' "${BREW_FORMULAE}" >"${BREW_FORMULAE_FILE}"
	set_brew_formulae() {
		BREW_FORMULAE=$1
		printf '%s\n' "${BREW_FORMULAE}" | tr ' ' '\n' >"${BREW_FORMULAE_FILE}"
	}
	brew() {
		operation=$1
		shift
		case "${operation}" in
		list)
			case "$1" in
			--formula) cat "${BREW_FORMULAE_FILE}" ;;
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
				printf '%s\n' "${BREW_FORMULAE}" >"${BREW_FORMULAE_FILE}"
			fi
			;;
		uninstall)
			printf 'uninstall %s\n' "$*" >>"${BREW_LOG}"
			case "${BREW_UNINSTALL_MODE:-success}" in
			missing-keg)
				printf 'present\n' >"${BREW_FORMULAE_FILE}"
				printf 'Error: No such keg: /opt/homebrew/Cellar/dnsmasq\n' >&2
				return 1
				;;
			stale-keg)
				printf 'Error: No such keg: /opt/homebrew/Cellar/dnsmasq\n' >&2
				return 1
				;;
			failure)
				printf 'Error: Permission denied while uninstalling formula\n' >&2
				return 24
				;;
			success)
				[ "${1:-}" = remove-me ] || return 2
				printf 'present\n' >"${BREW_FORMULAE_FILE}"
				;;
			*) return 2 ;;
			esac
			;;
		*) return 2 ;;
		esac
	}

	install_missing_brew_formulas present new-formula
	install_missing_brew_formulas present new-formula
	assert_eq "$(grep -Fc 'install new-formula' "${BREW_LOG}")" '1'

	set_brew_formulae 'present remove-me'
	BREW_UNINSTALL_MODE=success
	uninstall_brew_formulas remove-me
	assert_eq "$(brew list --formula)" 'present'
	assert_file_contains 'uninstall remove-me' "${BREW_LOG}"

	set_brew_formulae 'present dnsmasq'
	BREW_UNINSTALL_MODE='missing-keg'
	if ! uninstall_brew_formulas dnsmasq >"${tmp}/brew-missing-keg.log" 2>&1; then
		fail_test 'a formula that disappeared before uninstall should be tolerated'
	fi
	assert_file_contains "Formula 'dnsmasq' is already absent; continuing" "${tmp}/brew-missing-keg.log"
	if grep -Fq 'Error: No such keg:' "${tmp}/brew-missing-keg.log"; then
		fail_test 'the expected missing-formula error should not be reported'
	fi

	set_brew_formulae 'present dnsmasq'
	BREW_UNINSTALL_MODE='stale-keg'
	if uninstall_brew_formulas dnsmasq 2>"${tmp}/brew-stale-keg.log"; then
		fail_test 'a formula still reported as installed after a missing-keg error should fail'
	else
		brew_status=$?
	fi
	assert_eq "${brew_status}" '1'
	assert_file_contains 'Error: No such keg:' "${tmp}/brew-stale-keg.log"

	set_brew_formulae 'present failing-formula'
	BREW_UNINSTALL_MODE=failure
	if uninstall_brew_formulas failing-formula 2>"${tmp}/brew-uninstall-error.log"; then
		fail_test 'a genuine brew uninstall failure should be returned'
	else
		brew_status=$?
	fi
	assert_eq "${brew_status}" '24'
	assert_file_contains 'Error: Permission denied while uninstalling formula' "${tmp}/brew-uninstall-error.log"
	for leftover in "${TMPDIR}"/dotfiles-brew-uninstall.*; do
		[ ! -e "${leftover}" ] || fail_test "brew uninstall temp file leaked: ${leftover}"
	done

	set_brew_formulae 'present'
	BREW_UNINSTALL_MODE=success
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

	assert_eq "$(rust_tool_command cargo-edit)" 'cargo-add'
	assert_eq "$(rust_tool_command bottom)" 'btm'
	assert_eq "$(rust_tool_command du-dust)" 'dust'
	assert_eq "$(rust_tool_command taplo-cli)" 'taplo'
	platform=linux
	set_rust_tool_list
	assert_eq "${rust_tool_list}" 'cargo-audit cargo-deny cargo-edit cargo-nextest sccache bottom du-dust prek taplo-cli topgrade'
	platform=mac
	set_rust_tool_list
	assert_eq "${rust_tool_list}" 'cargo-audit cargo-deny cargo-edit cargo-nextest sccache'
	platform=linux
	set_rust_tool_list

	RUST_LOG="${tmp}/rust.log"
	TAPLO_CURL_LOG="${tmp}/taplo-curl.log"
	TAPLO_CURL_FAIL=0
	TAPLO_ARCHIVE="${tmp}/taplo.gz"
	TAPLO_URL='https://github.com/tamasfe/taplo/releases/latest/download/taplo-linux-x86_64.gz'
	export RUST_LOG TAPLO_CURL_LOG TAPLO_CURL_FAIL TAPLO_ARCHIVE TAPLO_URL
	mkdir -p "${tmp}/bin"
	cat >"${tmp}/bin/cargo-binstall" <<'EOF'
#!/bin/sh
exit 0
EOF
	cat >"${tmp}/taplo-fixture" <<'EOF'
#!/bin/sh
printf 'prebuilt Taplo\n'
EOF
	gzip -c "${tmp}/taplo-fixture" >"${TAPLO_ARCHIVE}"
	chmod +x "${tmp}/bin/cargo-binstall"
	PATH="${tmp}/bin:${PATH}"
	export PATH
	rustup() {
		printf 'rustup %s\n' "$*" >>"${RUST_LOG}"
	}
	cargo() {
		printf 'cargo %s\n' "$*" >>"${RUST_LOG}"
		if [ -n "${FAIL_RUST_TOOL:-}" ]; then
			case " $* " in
			*" ${FAIL_RUST_TOOL} "*) return 25 ;;
			esac
		fi
	}
	# shellcheck disable=SC2317,SC2329
	curl() {
		printf '%s\n' "$*" >>"${TAPLO_CURL_LOG}"
		[ "${TAPLO_CURL_FAIL}" -eq 0 ] || return 22
		[ "${1:-}" = -fsSL ] && [ "${2:-}" = "${TAPLO_URL}" ] && [ "${3:-}" = -o ] || return 2
		cp -- "${TAPLO_ARCHIVE}" "$4"
	}
	should_upgrade=1
	FAIL_RUST_TOOL=cargo-edit
	if maybe_upgrade_rust; then
		fail_test 'Rust tool update should preserve a child failure'
	else
		rust_status=$?
	fi
	assert_eq "${rust_status}" '1'
	assert_file_contains 'cargo binstall --disable-strategies compile --disable-telemetry -y --force cargo-edit' "${RUST_LOG}"
	if grep -Fq 'cargo-nextest' "${RUST_LOG}"; then
		fail_test 'Rust updates should stop after the first failed tool'
	fi

	FAIL_RUST_TOOL=''
	install_rust_tool cargo-audit
	assert_file_contains 'cargo binstall --disable-strategies compile --disable-telemetry -y cargo-audit' "${RUST_LOG}"
	FAIL_RUST_TOOL='missing-binary'
	if install_rust_tool missing-binary; then
		fail_test 'missing prebuilt Rust tools should fail instead of compiling'
	else
		rust_status=$?
	fi
	assert_eq "${rust_status}" '1'
	if grep -Fq 'cargo install ' "${RUST_LOG}"; then
		fail_test 'Rust tools must never be compiled from source'
	fi

	FAIL_RUST_TOOL=''
	install_rust_tool taplo-cli
	assert_file_contains "${TAPLO_URL}" "${TAPLO_CURL_LOG}"
	assert_eq "$("${CARGO_HOME}/bin/taplo")" 'prebuilt Taplo'
	if grep -Eq 'cargo binstall .*taplo-cli' "${RUST_LOG}"; then
		fail_test 'Taplo should be installed from its upstream prebuilt release'
	fi
	TAPLO_CURL_FAIL=1
	if install_rust_tool taplo-cli 2>"${tmp}/taplo-error.log"; then
		fail_test 'a failed Taplo download should preserve the prior binary and fail'
	else
		taplo_status=$?
	fi
	assert_eq "${taplo_status}" '1'
	assert_eq "$("${CARGO_HOME}/bin/taplo")" 'prebuilt Taplo'
	assert_file_contains "Could not download or prepare Taplo's prebuilt release binary" "${tmp}/taplo-error.log"
	for leftover in "${CARGO_HOME}/bin"/taplo.* "${TMPDIR}"/dotfiles-download.*; do
		[ ! -e "${leftover}" ] || fail_test "Taplo installer temp file leaked: ${leftover}"
	done

	TAPLO_CURL_FAIL=0
	: >"${RUST_LOG}"
	: >"${TAPLO_CURL_LOG}"
	maybe_upgrade_rust
	assert_file_contains 'cargo binstall --disable-strategies compile --disable-telemetry -y --force cargo-audit' "${RUST_LOG}"
	assert_eq "$(grep -Fc "${TAPLO_URL}" "${TAPLO_CURL_LOG}")" '1'
	assert_eq "$("${CARGO_HOME}/bin/taplo")" 'prebuilt Taplo'
	if grep -Fq 'cargo install ' "${RUST_LOG}"; then
		fail_test 'Rust tool updates must never compile from source'
	fi

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

	VIM_HOME="${tmp}/vim home"
	VIM_LOG="${tmp}/vim.log"
	HOME=${VIM_HOME}
	export HOME VIM_LOG
	vim() { printf '%s\n' "$*" >>"${VIM_LOG}"; }
	: >"${CURL_LOG}"
	setup_vim_plugins
	plug_file="${VIM_HOME}/.vim/autoload/plug.vim"
	assert_file_contains 'ran' "${plug_file}"
	assert_file_contains 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' "${CURL_LOG}"
	assert_file_contains 'PlugInstall --sync' "${VIM_LOG}"
	CURL_FAIL=1
	rm -f -- "${plug_file}"
	if (setup_vim_plugins) >"${tmp}/vim-install.out" 2>&1; then
		fail_test 'vim-plug download failure should be returned'
	fi
	[ ! -e "${plug_file}" ] || fail_test 'failed vim-plug download activated a file'
	for leftover in "${plug_file}".* "${TMPDIR}"/dotfiles-download.*; do
		[ ! -e "${leftover}" ] || fail_test "vim-plug temp file leaked: ${leftover}"
	done
	CURL_FAIL=0

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
	for leftover in "${TMPDIR}"/dotfiles-download.*; do
		[ ! -e "${leftover}" ] || fail_test "binary temp directory leaked: ${leftover}"
	done

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

	TEA_HOME="${tmp}/Gitea tea home"
	TEA_BIN="${TEA_HOME}/.local/bin/tea"
	TEA_ARCHIVE="${tmp}/tea release"
	TEA_CURL_LOG="${tmp}/tea curl.log"
	TEA_CURL_FAIL=0
	mkdir -p "${TEA_HOME}"
	export TEA_ARCHIVE TEA_CURL_LOG TEA_CURL_FAIL
	require_linux_x86_64() { :; }
	write_tea_fixture() {
		fixture_version=$1
		cat >"${TEA_ARCHIVE}" <<EOF
#!/bin/sh
[ "\${1:-}" = --version ] || exit 2
printf 'Version: %s\\n' '${fixture_version}'
EOF
		chmod +x "${TEA_ARCHIVE}"
	}
	curl() {
		printf '%s\n' "$*" >>"${TEA_CURL_LOG}"
		[ "${1:-}" = -fsSL ] || return 2
		[ "${2:-}" = https://dl.gitea.com/tea/0.16.0/tea-0.16.0-linux-amd64 ] || return 2
		[ "${3:-}" = -o ] && [ -n "${4:-}" ] || return 2
		[ "${TEA_CURL_FAIL}" -eq 0 ] || return 22
		cp -- "${TEA_ARCHIVE}" "$4"
	}
	HOME=${TEA_HOME}
	export HOME
	should_upgrade=0
	write_tea_fixture 0.16.0
	install_tea_linux
	assert_eq "$("${TEA_BIN}" --version)" 'Version: 0.16.0'
	assert_eq "$(grep -Fc 'tea-0.16.0-linux-amd64 -o' "${TEA_CURL_LOG}")" '1'
	tea_curl_calls=$(wc -l <"${TEA_CURL_LOG}" | tr -d ' ')
	install_tea_linux
	assert_eq "$(wc -l <"${TEA_CURL_LOG}" | tr -d ' ')" "${tea_curl_calls}"
	should_upgrade=1
	install_tea_linux
	assert_eq "$(wc -l <"${TEA_CURL_LOG}" | tr -d ' ')" "${tea_curl_calls}"

	write_tea_fixture 0.15.0
	cp -- "${TEA_ARCHIVE}" "${TEA_BIN}"
	write_tea_fixture 0.16.0
	install_tea_linux
	assert_eq "$("${TEA_BIN}" --version)" 'Version: 0.16.0'
	assert_eq "$(grep -Fc 'tea-0.16.0-linux-amd64 -o' "${TEA_CURL_LOG}")" '2'

	write_tea_fixture 0.15.0
	cp -- "${TEA_ARCHIVE}" "${TEA_BIN}"
	TEA_CURL_FAIL=1
	if install_tea_linux 2>"${tmp}/tea-download-error.log"; then
		fail_test 'a failed tea download should fail'
	else
		tea_status=$?
	fi
	assert_eq "${tea_status}" '1'
	assert_eq "$("${TEA_BIN}" --version)" 'Version: 0.15.0'
	assert_file_contains 'Could not download or prepare Gitea tea 0.16.0' "${tmp}/tea-download-error.log"
	assert_eq "$(grep -Fc 'tea-0.16.0-linux-amd64 -o' "${TEA_CURL_LOG}")" '3'
	for leftover in "${TEA_BIN}".* "${TMPDIR}"/dotfiles-download.*; do
		[ ! -e "${leftover}" ] || fail_test "binary installer temp file leaked: ${leftover}"
	done

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
install_tea_linux() { record_install_call install_tea_linux; }
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
	assert_eq "$(grep -Fc 'install_tea_linux' "${INSTALL_LOG}")" '2'
	assert_eq "$(grep -Fc 'install_tailscale_linux' "${INSTALL_LOG}")" '2'
	assert_eq "$(grep -Fc 'install_docker_linux' "${INSTALL_LOG}")" '2'
	assert_eq "$(grep -Fc 'install_keymapp' "${INSTALL_LOG}")" '2'
)

run_setup_install_tests

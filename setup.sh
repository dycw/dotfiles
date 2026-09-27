#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2034,SC2086,SC2154

set -eu

case "$0" in
/*) self_path=$0 ;;
*) self_path=$(pwd -P)/$0 ;;
esac
self_dir=$(CDPATH='' cd -- "$(dirname -- "$self_path")" && pwd -P)

#### utilities ################################################################

# Prevent brew from consuming stdin when the script is run via 'curl | sh'.
# Disable silent auto-update; we call 'brew update' explicitly where needed.
export HOMEBREW_NO_AUTO_UPDATE=1
brew() { command brew "$@" </dev/null; }

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

fail() {
	log "$*" >&2
	exit 1
}

acquire_sudo() {
	if [ "$(id -u)" -eq 0 ] || sudo -n true >/dev/null 2>&1; then
		return 0
	fi
	log "Requesting sudo access..."
	sudo -v
}

run_root() {
	if [ "$1" = apt-get ]; then
		if [ "$(id -u)" -eq 0 ]; then
			DEBIAN_FRONTEND=noninteractive "$@"
		else
			acquire_sudo
			sudo env PATH="${PATH}:/usr/local/sbin:/usr/sbin:/sbin" DEBIAN_FRONTEND=noninteractive "$@"
		fi
	elif [ "$(id -u)" -eq 0 ]; then
		"$@"
	else
		acquire_sudo
		sudo env PATH="${PATH}:/usr/local/sbin:/usr/sbin:/sbin" "$@"
	fi
}

add_brew_to_path() {
	[ "${platform:-}" = mac ] || return 0
	if [ -x /opt/homebrew/bin/brew ]; then
		export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH:+:${PATH}}"
	elif [ -x /usr/local/bin/brew ]; then
		export PATH="/usr/local/bin:/usr/local/sbin${PATH:+:${PATH}}"
	fi
}

run_script_from_url() (
	_script_url=$1
	shift
	if ! _script_tmp=$(mktemp "${TMPDIR:-/tmp}/dotfiles-installer.XXXXXX"); then
		log "Could not create a temporary installer file" >&2
		exit 1
	fi
	trap '_script_status=$?; rm -f -- "${_script_tmp}"; exit "${_script_status}"' EXIT
	trap 'exit 1' HUP INT TERM
	if ! curl -fsSL "${_script_url}" -o "${_script_tmp}"; then
		log "Failed to download installer from ${_script_url}" >&2
		exit 1
	fi
	if "$@" <"${_script_tmp}"; then
		exit 0
	else
		_script_status=$?
		exit "${_script_status}"
	fi
)

require_linux() {
	if [ ! -r /etc/os-release ]; then
		fail "'/etc/os-release' is not readable; exiting..."
	fi
	. /etc/os-release
	if [ "${ID:-}" != debian ]; then
		fail "Unsupported Linux distribution '${ID:-unknown}'; exiting..."
	fi
}

determine_platform() {
	case "$(uname)" in
	Linux)
		require_linux
		platform=linux
		export PATH="${PATH}:/usr/local/sbin:/usr/sbin:/sbin"
		;;
	Darwin)
		platform=mac
		case "$(sysctl -n hw.model 2>/dev/null || true)" in
		Mac14,3) machine=rh_mac_mini ;;
		Mac14,12) machine=dw_mac_mini ;;
		MacBook*) machine=dw_macbook_neo ;;
		*) machine=unknown ;;
		esac
		;;
	*)
		fail "Unsupported platform '$(uname)'; exiting..."
		;;
	esac
	add_brew_to_path
}

#### files ####################################################################

link_home() {
	src=$1
	dest=$2
	[ -e "${src}" ] || fail "Config source does not exist: ${src}"
	mkdir -p "$(dirname -- "${HOME}/${dest}")"
	ln -sfn "${src}" "${HOME}/${dest}"
}

link_config() {
	src=$1
	dest=$2
	[ -e "${src}" ] || fail "Config source does not exist: ${src}"
	mkdir -p "$(dirname -- "${xdg_config_home}/${dest}")"
	ln -sfn "${src}" "${xdg_config_home}/${dest}"
}

link_direct() {
	src=$1
	dest=$2
	[ -e "${src}" ] || fail "Config source does not exist: ${src}"
	mkdir -p "$(dirname -- "${dest}")"
	ln -sfn "${src}" "${dest}"
}

ensure_line_in_file() {
	line=$1
	path=$2
	if [ ! -f "${path}" ]; then
		printf '%s\n' "${line}" >"${path}"
		return
	fi
	if ! grep -Fqx -- "${line}" "${path}"; then
		if [ -s "${path}" ] && [ -n "$(tail -c 1 "${path}")" ]; then
			printf '\n' >>"${path}"
		fi
		printf '%s\n' "${line}" >>"${path}"
	fi
}

merge_authorized_keys() {
	source=$1
	destination=$2
	[ -f "${source}" ] || fail "Authorized keys source does not exist: ${source}"
	[ ! -d "${destination}" ] || fail "Authorized keys destination is a directory: ${destination}"
	if [ ! -f "${destination}" ]; then
		cp -- "${source}" "${destination}"
		return 0
	fi
	while IFS= read -r key || [ -n "${key}" ]; do
		[ -n "${key}" ] || continue
		ensure_line_in_file "${key}" "${destination}"
	done <"${source}"
}

#### brew #####################################################################

upgrade_timer="${XDG_CACHE_HOME:-${HOME}/.cache}/dotfiles/updated"

# True if upgrades have not run successfully in the last hour.
should_upgrade() {
	[ -f "${upgrade_timer}" ] || return 0
	[ -n "$(find "${upgrade_timer}" -mmin +60 -print 2>/dev/null)" ]
}

mark_upgraded() {
	mkdir -p -- "$(dirname -- "${upgrade_timer}")"
	: >"${upgrade_timer}"
}

ensure_brew() {
	if command brew --version >/dev/null 2>&1; then
		return
	fi
	log "Installing 'brew'..."
	acquire_sudo
	if ! run_script_from_url https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh env NONINTERACTIVE=1 HOMEBREW_NO_ENV_HINTS=1 /bin/bash -s; then
		fail "'brew' installation failed"
	fi
	add_brew_to_path
	command brew --version >/dev/null 2>&1 || fail "'brew' installation failed"
	log "'brew' installed successfully"
}

list_has_line() {
	printf '%s\n' "$1" | grep -Fqx -- "$2"
}

install_missing_apt_packages() {
	missing=''
	for package in "$@"; do
		if ! dpkg -s "${package}" >/dev/null 2>&1; then
			missing="${missing}${missing:+ }${package}"
		fi
	done
	[ -n "${missing}" ] || return 0
	log "Updating apt package indexes..."
	run_root apt-get -o DPkg::Lock::Timeout=300 update
	log "Installing packages: ${missing}"
	# Package names are fixed by the callers and contain no whitespace.
	# shellcheck disable=SC2086
	run_root apt-get -o DPkg::Lock::Timeout=300 install -y --no-install-recommends ${missing}
}

uninstall_brew_formulas() {
	if ! installed=$(brew list --formula); then
		fail "Could not list installed brew formulae"
	fi
	present=''
	for formula in "$@"; do
		if list_has_line "${installed}" "${formula}"; then
			present="${present}${present:+ }${formula}"
		fi
	done
	[ -n "${present}" ] || return 0
	log "Uninstalling formulae: ${present}"
	# Formula names are fixed by the callers and contain no whitespace.
	# shellcheck disable=SC2086
	brew uninstall ${present}
}

uninstall_brew_casks() {
	if ! installed=$(brew list --cask); then
		fail "Could not list installed brew casks"
	fi
	present=''
	for cask in "$@"; do
		if list_has_line "${installed}" "${cask}"; then
			present="${present}${present:+ }${cask}"
		fi
	done
	[ -n "${present}" ] || return 0
	log "Uninstalling casks: ${present}"
	# Cask names are fixed by the callers and contain no whitespace.
	# shellcheck disable=SC2086
	brew uninstall --cask ${present}
}

install_missing_brew_formulas() {
	if ! installed=$(brew list --formula); then
		fail "Could not list installed brew formulae"
	fi
	missing=''
	for formula in "$@"; do
		if ! list_has_line "${installed}" "${formula}"; then
			missing="${missing}${missing:+ }${formula}"
		fi
	done
	[ -n "${missing}" ] || return 0
	log "Installing formulae: ${missing}"
	# Formula names are fixed by the callers and contain no whitespace.
	# shellcheck disable=SC2086
	brew install ${missing}
}

# Uses --adopt to handle apps installed outside Homebrew.
install_missing_brew_casks() {
	if ! installed=$(brew list --cask); then
		fail "Could not list installed brew casks"
	fi
	missing=''
	for cask in "$@"; do
		if ! list_has_line "${installed}" "${cask}"; then
			missing="${missing}${missing:+ }${cask}"
		fi
	done
	[ -n "${missing}" ] || return 0
	log "Installing casks: ${missing}"
	# Cask names are fixed by the callers and contain no whitespace.
	# shellcheck disable=SC2086
	brew install --cask --adopt ${missing}
}

maybe_upgrade_brew_formulas() {
	[ "${should_upgrade:-0}" -eq 1 ] || return 0
	log "Updating brew formula database..."
	brew update
	log "Upgrading brew formulae..."
	brew upgrade
}

maybe_upgrade_brew_casks() {
	[ "${should_upgrade:-0}" -eq 1 ] || return 0
	log "Upgrading brew casks..."
	brew upgrade --cask
}

maybe_upgrade_apt_packages() {
	[ "${should_upgrade:-0}" -eq 1 ] || return 0
	log "Upgrading apt packages..."
	run_root apt-get -o DPkg::Lock::Timeout=300 upgrade -y
}

set_rust_tool_list() {
	rust_tool_list='bacon cargo-audit cargo-deny cargo-edit cargo-nextest sccache'
	if [ "${platform:-}" = linux ]; then
		rust_tool_list="${rust_tool_list} bottom du-dust prek taplo-cli topgrade"
	fi
}

rust_tool_command() {
	case "$1" in
	bottom) printf 'btm' ;;
	cargo-edit) printf 'cargo-add' ;;
	du-dust) printf 'dust' ;;
	taplo-cli) printf 'taplo' ;;
	*) printf '%s' "$1" ;;
	esac
}

install_rust_tool() {
	tool=$1
	if [ "${tool}" = taplo-cli ]; then
		log "Installing '${tool}' using 'cargo install'..."
		cargo install --locked "${tool}"
		return
	fi

	log "Installing '${tool}' using 'cargo binstall'..."
	if ! cargo binstall -y "${tool}"; then
		log "Installing '${tool}' using 'cargo install'..."
		cargo install --locked "${tool}"
	fi
}

maybe_upgrade_rust() {
	[ "${should_upgrade:-0}" -eq 1 ] || return 0
	export PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}"
	command -v rustup >/dev/null 2>&1 || return 0
	command -v cargo-binstall >/dev/null 2>&1 || return 0
	log "Updating rust toolchain and cargo tools..."
	if ! rustup update; then
		return 1
	fi
	set_rust_tool_list
	# Tool package names are fixed by set_rust_tool_list.
	for tool in ${rust_tool_list}; do
		if ! cargo binstall -y --force "${tool}"; then
			log "Failed to update Rust tool '${tool}'" >&2
			return 1
		fi
	done
}

#### packages #################################################################

remove_unwanted_brew_formulas() {
	uninstall_brew_formulas age dnsmasq sops rlwrap yoannfleurydev/gitweb/gitweb
	case "${platform}" in
	mac)
		uninstall_brew_formulas tailscale
		;;
	esac
}

install_common_brew_formulas() {
	install_missing_brew_formulas \
		asciinema autoconf automake bat bash bash-completion@2 bottom coreutils delta \
		direnv dust eza fd fzf gh git-delta iperf3 jq just libpq \
		luacheck luarocks markdownlint-cli maturin npm pgcli postgresql@18 prek prettier redis \
		restic ripgrep ruff sccache sd shellcheck shfmt starship taplo \
		tea tmux topgrade uv vim watch yq zoxide

	install_missing_brew_formulas agg flock mas rename wakeonlan
}

install_linux_packages() {
	install_missing_apt_packages \
		asciinema autoconf automake bat bash bash-completion build-essential ca-certificates coreutils direnv eza \
		fd-find fzf gh git-delta golang-go iperf3 jq just libpq-dev lua-check luarocks pgcli \
		postgresql passwd procps python3-maturin python3-pip python3-venv pipx redis-server restic \
		ripgrep sccache sd shellcheck \
		shfmt starship tmux vim yq zoxide curl rsync sudo xclip xsel
}

ensure_nodejs_22() {
	if command -v node >/dev/null 2>&1; then
		node_version=$(node --version | cut -c 2-)
		node_major=${node_version%%.*}
		node_rest=${node_version#*.}
		node_minor=${node_rest%%.*}
		node_patch=${node_rest#*.}
		if {
			[ "${node_major}" -gt 22 ] ||
				{ [ "${node_major}" -eq 22 ] && [ "${node_minor}" -gt 22 ]; } ||
				{ [ "${node_major}" -eq 22 ] && [ "${node_minor}" -eq 22 ] && [ "${node_patch}" -ge 2 ]; }
		} && command -v npm >/dev/null 2>&1; then
			return 0
		fi
	fi

	log "Installing Node.js 22 or newer..."
	acquire_sudo
	if ! run_script_from_url https://deb.nodesource.com/setup_22.x sudo -E /bin/bash -s; then
		fail "Node.js repository setup failed"
	fi
	run_root apt-get -o DPkg::Lock::Timeout=300 install -y --no-install-recommends nodejs
	command -v npm >/dev/null 2>&1 || fail "Node.js installation did not provide npm"
}

install_linux_user_tools() {
	export PATH="${HOME}/.local/bin:${HOME}/.npm-global/bin${PATH:+:${PATH}}"

	if [ "${should_upgrade:-0}" -eq 1 ] || ! command -v ruff >/dev/null 2>&1; then
		pipx install --force ruff
	fi
	if [ "${should_upgrade:-0}" -eq 1 ] || ! command -v uv >/dev/null 2>&1; then
		pipx install --force uv
	fi

	npm_packages=''
	if [ "${should_upgrade:-0}" -eq 1 ] || [ ! -x "${HOME}/.npm-global/bin/markdownlint" ]; then
		npm_packages=markdownlint-cli@0.48.0
	fi
	if [ "${should_upgrade:-0}" -eq 1 ] || [ ! -x "${HOME}/.npm-global/bin/prettier" ]; then
		npm_packages="${npm_packages}${npm_packages:+ }prettier"
	fi
	[ -n "${npm_packages}" ] || return 0
	log "Installing npm tools: ${npm_packages}"
	# Package names are fixed above and contain no whitespace.
	# shellcheck disable=SC2086
	npm install --global --prefix "${HOME}/.npm-global" ${npm_packages}
}

install_tailscale_linux() {
	if command -v tailscale >/dev/null 2>&1; then
		return 0
	fi
	log "Installing tailscale from the upstream Debian repository..."
	acquire_sudo
	if ! run_script_from_url https://tailscale.com/install.sh /bin/sh; then
		fail "Tailscale installation failed"
	fi
	command -v tailscale >/dev/null 2>&1 || fail "Tailscale installation failed"
}

install_docker_linux() {
	if ! command -v docker >/dev/null 2>&1; then
		log "Installing docker via upstream script..."
		acquire_sudo
		if ! run_script_from_url https://get.docker.com /bin/sh -s; then
			fail "Docker installation failed"
		fi
	fi
	command -v docker >/dev/null 2>&1 || fail "Docker installation failed"
	if ! id -nG "${USER}" | tr ' ' '\n' | grep -Fqx -- docker; then
		run_root usermod -aG docker "${USER}"
	fi
}

remove_unwanted_brew_casks() {
	uninstall_brew_casks \
		db-browser-for-sqlite firefox ghostty google-chrome iterm2 pgadmin4 slack
}

ensure_brew_taps() {
	brew tap redis-stack/redis-stack
}

install_mac_casks() {
	ensure_brew_taps
	casks='1password a-better-finder-attributes a-better-finder-rename chatgpt dropbox handy postico protonvpn redis-stack spotify telegram transmission vlc wezterm whatsapp zoom'
	case "${machine:-}" in
	dw_macbook_neo) ;;
	*)
		casks="${casks} docker"
		;;
	esac
	# shellcheck disable=SC2086
	install_missing_brew_casks ${casks}
}

# 1Password for Safari (App Store id 1569813296)
# Tailscale (App Store id 1475387147)
mac_app_store_apps='1569813296 1475387147'

install_missing_mas_apps() {
	installed=$(mas list 2>/dev/null || true)
	missing=''
	for app_id in "$@"; do
		if ! printf '%s\n' "${installed}" | awk '{print $1}' | grep -Fqx -- "${app_id}"; then
			missing="${missing}${missing:+ }${app_id}"
		fi
	done
	[ -n "${missing}" ] || return 0
	log "Installing Mac App Store apps: ${missing}"
	# App IDs are fixed by the caller and contain no whitespace.
	for app_id in ${missing}; do
		mas install "${app_id}" || log "Warning: failed to install App Store app ${app_id}; sign in to the App Store and re-run"
	done
}

install_mac_app_store_apps() {
	command -v mas >/dev/null 2>&1 || return 0
	# shellcheck disable=SC2086
	install_missing_mas_apps ${mac_app_store_apps}
}

maybe_upgrade_mas_apps() {
	[ "${should_upgrade:-0}" -eq 1 ] || return 0
	command -v mas >/dev/null 2>&1 || return 0
	log "Upgrading Mac App Store apps..."
	mas upgrade || log "Warning: 'mas upgrade' failed; sign in to the App Store and re-run"
}

install_rust_tools() {
	export PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}"

	if command -v rustup >/dev/null 2>&1; then
		log "'rust' is already installed"
	else
		log "Installing 'rust'..."
		if [ "${platform}" = linux ]; then
			run_script_from_url https://sh.rustup.rs /bin/sh -s -- -y --no-modify-path --profile minimal
		else
			run_script_from_url https://sh.rustup.rs /bin/sh -s -- -y --no-modify-path
		fi
		. "${HOME}/.cargo/env"
	fi

	if ! rustup show active-toolchain >/dev/null 2>&1; then
		log "Installing default rust toolchain..."
		rustup toolchain install stable
		rustup default stable
		rustup component add clippy rust-analyzer rustfmt
		if [ "${platform}" = mac ]; then
			rustup component add rust-docs
			rustup target add x86_64-unknown-linux-gnu x86_64-apple-darwin aarch64-apple-darwin
		fi
	fi

	command -v cargo >/dev/null 2>&1 || fail "'cargo' is still not available after rustup setup"

	if command -v cargo-binstall >/dev/null 2>&1; then
		log "'cargo-binstall' is already installed"
	else
		log "Installing 'cargo-binstall'..."
		run_script_from_url \
			https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
			/bin/bash -s
	fi

	set_rust_tool_list
	# Tool package names are fixed by set_rust_tool_list.
	for tool in ${rust_tool_list}; do
		tool_command=$(rust_tool_command "${tool}")
		if command -v "${tool_command}" >/dev/null 2>&1; then
			log "'${tool}' is already installed"
		else
			install_rust_tool "${tool}"
		fi
	done
}

install_keymapp() (
	keymapp_bin="${HOME}/.local/bin/keymapp"
	if [ "${should_upgrade:-0}" -ne 1 ] && [ -x "${keymapp_bin}" ]; then
		exit 0
	fi

	log "Installing 'keymapp'..."
	if ! tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-keymapp.XXXXXX"); then
		fail "Could not create a temporary keymapp directory"
	fi
	staged=''
	trap '_keymapp_status=$?; rm -rf -- "${tmp}"; if [ -n "${staged}" ]; then rm -f -- "${staged}"; fi; exit "${_keymapp_status}"' EXIT
	trap 'exit 1' HUP INT TERM
	url='https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz'
	if ! curl -fsSL "${url}" -o "${tmp}/keymapp.tar.gz"; then
		fail "Could not download keymapp"
	fi
	if ! tar -xz -f "${tmp}/keymapp.tar.gz" -C "${tmp}"; then
		fail "Could not extract keymapp"
	fi
	keymapp_dir=$(dirname -- "${keymapp_bin}")
	mkdir -p -- "${keymapp_dir}"
	if ! staged=$(mktemp "${keymapp_bin}.XXXXXX"); then
		fail "Could not create a staged keymapp binary"
	fi
	if ! install -m 755 "${tmp}/keymapp" "${staged}"; then
		fail "Could not stage keymapp"
	fi
	if ! mv -f -- "${staged}" "${keymapp_bin}"; then
		fail "Could not activate keymapp at ${keymapp_bin}"
	fi
	staged=''
)

install_all() {
	log "Installing apps on '$(hostname)'..."

	should_upgrade=0
	if should_upgrade; then
		should_upgrade=1
		log "Upgrade timer expired; will refresh installed packages"
	fi

	case "${platform}" in
	linux)
		install_linux_packages
		maybe_upgrade_apt_packages
		ensure_nodejs_22
		maybe_upgrade_rust
		install_rust_tools
		install_linux_user_tools
		install_tailscale_linux
		install_docker_linux
		install_keymapp
		;;
	mac)
		ensure_brew
		remove_unwanted_brew_formulas
		maybe_upgrade_brew_formulas
		install_common_brew_formulas
		maybe_upgrade_rust
		install_rust_tools
		remove_unwanted_brew_casks
		install_mac_casks
		maybe_upgrade_brew_casks
		install_mac_app_store_apps
		maybe_upgrade_mas_apps
		;;
	esac

	if [ "${should_upgrade}" -eq 1 ]; then
		mark_upgraded
	fi
}

#### setup ####################################################################

setup_ssh() {
	log "Setting up 'ssh'..."
	mkdir -p "${HOME}/.ssh"
	run_root chown -R "$(id -un)" "${HOME}/.ssh"
	chmod 700 "${HOME}/.ssh"

	merge_authorized_keys "${configs}/authorized_keys" "${HOME}/.ssh/authorized_keys"
	chmod 600 "${HOME}/.ssh/authorized_keys"

	mkdir -p "${HOME}/.ssh/config.d"
	chmod 700 "${HOME}/.ssh/config.d"
	ensure_line_in_file 'Include ~/.ssh/config.d/*' "${HOME}/.ssh/config"
	chmod 600 "${HOME}/.ssh/config"

	case "${platform:-}" in
	mac)
		if ! nc -z 127.0.0.1 22 2>/dev/null; then
			run_root launchctl enable system/com.openssh.sshd
		fi
		;;
	esac
}

setup_bash() {
	log "Setting up 'bash'..."
	link_home "${configs}/bash/bashrc" .bashrc
	link_home "${configs}/bash/bash_profile" .bash_profile
	setup_bash_profile_d
	setup_bashrc_d
	if command -v bash >/dev/null 2>&1; then
		bash_path=$(command -v bash)
		current_shell=''
		if [ "$(uname)" = Darwin ]; then
			current_shell=$(dscl . -read "/Users/${USER}" UserShell 2>/dev/null | awk '{print $2}' || true)
		elif command -v getent >/dev/null 2>&1; then
			current_shell=$(getent passwd "${USER}" 2>/dev/null | cut -d: -f7 || true)
		fi
		if [ -n "${current_shell}" ] && [ "${current_shell}" != "${bash_path}" ]; then
			if ! grep -Fxq "${bash_path}" /etc/shells 2>/dev/null; then
				run_root sh -c "printf '%s\n' '${bash_path}' >> /etc/shells"
			fi
			run_root chsh -s "${bash_path}" "${USER}"
		fi
	fi
	if [ "${platform:-}" = mac ] && command brew --version >/dev/null 2>&1; then
		brew completions link 2>/dev/null || true
	fi
}

setup_bashrc_d() {
	mkdir -p "${HOME}/.bashrc.d"
	_src_dir="${configs}/bash/bashrc.d"
	[ -d "${_src_dir}" ] || return 0
	for _src in "${_src_dir}"/*.sh; do
		[ -f "${_src}" ] || continue
		_name=$(basename -- "${_src}")
		link_direct "${_src}" "${HOME}/.bashrc.d/${_name}"
	done
	unset _src_dir _src _name
}

setup_bash_profile_d() {
	mkdir -p "${HOME}/.bash_profile.d"
	_src_dir="${configs}/bash/profile.d"
	[ -d "${_src_dir}" ] || return 0
	for _src in "${_src_dir}"/*.sh; do
		[ -f "${_src}" ] || continue
		_name=$(basename -- "${_src}")
		link_direct "${_src}" "${HOME}/.bash_profile.d/${_name}"
	done
	unset _src_dir _src _name
}

setup_tailscale() {
	_ts_bin=''
	if command -v tailscale >/dev/null 2>&1; then
		_ts_bin=tailscale
	elif command -v Tailscale >/dev/null 2>&1; then
		_ts_bin=Tailscale
	fi
	[ -n "${_ts_bin}" ] || return 0

	template="${HOME}/.bashrc.d/tailscale.sh"
	if [ ! -e "${template}" ]; then
		mkdir -p -- "$(dirname -- "${template}")"
		cat >"${template}" <<'EOF'
#!/usr/bin/env bash
# Fill these in to enable headless 'tailscale up' from setup.sh.
export TAILSCALE_LOGIN_SERVER=
export TAILSCALE_AUTH_KEY=
EOF
		log "Created template ${template}; fill it in and re-run to bring tailscale up"
	fi

	# Skip the daemon restart and re-auth if already connected. Tailscale
	# assigns addresses in 100.64.0.0/10 (CGNAT); their presence on any
	# interface means the daemon is up and authenticated — no sudo needed.
	if ifconfig 2>/dev/null | grep -q 'inet 100\.64\.'; then
		return 0
	fi

	log "Starting tailscale daemon..."
	case "${platform}" in
	linux)
		# Write a systemd unit pointing at the brew binary so we don't depend
		# on a separately-installed system package.
		_tailscaled=$(command -v tailscaled)
		_svc=/etc/systemd/system/tailscaled.service
		if ! grep -qF "ExecStart=${_tailscaled}" "${_svc}" 2>/dev/null; then
			run_root sh -c "sed 's|TAILSCALED_BIN|${_tailscaled}|g' \
				'${configs}/tailscale/tailscaled.service' > '${_svc}'"
			run_root systemctl daemon-reload
		fi
		run_root systemctl enable --now tailscaled
		;;
	mac)
		# Mac App Store version manages its own daemon via launchd.
		if ! pgrep -f 'Tailscale' >/dev/null 2>&1; then
			open -a Tailscale 2>/dev/null || true
		fi
		;;
	esac

	if [ -z "${TAILSCALE_LOGIN_SERVER:-}" ] || [ -z "${TAILSCALE_AUTH_KEY:-}" ]; then
		log "TAILSCALE_LOGIN_SERVER or TAILSCALE_AUTH_KEY not set; skipping 'tailscale up'"
		return 0
	fi

	# `tailscale status` (no flag) errors with "Logged out." until BackendState
	# is Running, so on a fresh daemon it never succeeds. `--json` returns the
	# status object as long as the local API is reachable.
	log "Waiting for tailscaled to be ready..."
	i=0
	while ! run_root "${_ts_bin}" status --json >/dev/null 2>&1; do
		i=$((i + 1))
		[ "${i}" -lt 30 ] || fail "tailscaled did not become ready after 30 seconds"
		sleep 1
	done

	# tailscaled rejects login-server URLs without a scheme with
	# `unsupported protocol scheme ""` and retries forever, hanging
	# `tailscale up`. Default to https:// when no scheme was provided.
	case "${TAILSCALE_LOGIN_SERVER}" in
	https://* | http://*) ;;
	*) TAILSCALE_LOGIN_SERVER="https://${TAILSCALE_LOGIN_SERVER}" ;;
	esac

	ts_hostname=$(hostname -s)
	log "Bringing tailscale up as '${ts_hostname}'..."
	run_root "${_ts_bin}" up \
		--accept-dns --accept-routes \
		--auth-key "${TAILSCALE_AUTH_KEY}" \
		--hostname "${ts_hostname}" \
		--login-server "${TAILSCALE_LOGIN_SERVER}" \
		--reset \
		--timeout=30s
}

setup_macos_safari_defaults() {
	defaults write com.apple.Safari HomePage -string https://gitea.ai
	defaults write com.apple.Safari ShowTabBar -bool true
}

setup_macos_keyboard_defaults() {
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticTextReplacementEnabled -bool false
}

setup_macos_menu_bar_defaults() {
	defaults write com.apple.menuextra.clock ShowSeconds -bool true
	defaults write com.apple.controlcenter BatteryShowPercentage -bool true
}

setup_macos_dropbox_defaults() {
	[ -d "${HOME}/Dropbox" ] || return 0

	dropbox="${HOME}/Dropbox"
	temporary="${dropbox}/Temporary"
	mkdir -p -- "${temporary}"

	defaults write com.apple.finder NewWindowTarget -string PfLo
	defaults write com.apple.finder NewWindowTargetPath -string "file://${dropbox}/"
	defaults write com.apple.screencapture location -string "${temporary}"
	defaults write com.apple.Safari DownloadsPath -string "${temporary}"
}

setup_macos_defaults() {
	[ "${platform}" = mac ] || return 0

	log "Setting up macOS defaults..."
	setup_macos_safari_defaults
	setup_macos_keyboard_defaults
	setup_macos_menu_bar_defaults
	setup_macos_dropbox_defaults

	killall Finder >/dev/null 2>&1 || true
	killall SystemUIServer >/dev/null 2>&1 || true
}

setup_keymapp() {
	log "Setting up 'keymapp'..."
	run_root mkdir -p /etc/udev/rules.d
	run_root ln -sfn "${configs}/keymapp.50-zsa.rules" /etc/udev/rules.d/50-zsa.rules
}

setup_vim_plugins() {
	log "Setting up Vim plugins..."
	plug_file="${HOME}/.vim/autoload/plug.vim"
	if [ ! -s "${plug_file}" ]; then
		mkdir -p -- "$(dirname -- "${plug_file}")"
		if ! plug_tmp=$(mktemp "${plug_file}.XXXXXX"); then
			fail "Could not create a temporary vim-plug file"
		fi
		if ! curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -o "${plug_tmp}"; then
			rm -f -- "${plug_tmp}"
			fail "Could not download vim-plug"
		fi
		if [ ! -s "${plug_tmp}" ] || ! mv -f -- "${plug_tmp}" "${plug_file}"; then
			rm -f -- "${plug_tmp}"
			fail "Could not install vim-plug"
		fi
	fi
	vim -Nu "${HOME}/.vimrc" -n -es +'PlugInstall --sync' +qa
}

setup_git_config() {
	# [include] instead of symlink: reset --hard never wipes the user's global config.
	_git_cfg="${xdg_config_home}/git/config"
	mkdir -p "${xdg_config_home}/git"
	[ -L "${_git_cfg}" ] && rm -f -- "${_git_cfg}"
	if ! grep -qF "path = ${configs}/git/config" "${_git_cfg}" 2>/dev/null; then
		if [ -s "${_git_cfg}" ] && [ -n "$(tail -c 1 "${_git_cfg}")" ]; then
			printf '\n' >>"${_git_cfg}"
		fi
		printf '[include]\n\tpath = %s\n' "${configs}/git/config" >>"${_git_cfg}"
	fi
	unset _git_cfg
}

setup_ipython_configs() {
	link_direct "${configs}/ipython/ipython_config.py" "${HOME}/.ipython/profile_default/ipython_config.py"
	link_direct "${configs}/ipython/startup.py" "${HOME}/.ipython/profile_default/startup/startup.py"
}

link_jupyter_lab_setting() {
	link_direct \
		"${configs}/jupyter/$1" \
		"${xdg_config_home}/jupyter/lab/user-settings/$2"
}

setup_jupyter_configs() {
	link_direct "${configs}/jupyter/jupyter_lab_config.py" "${xdg_config_home}/jupyter/jupyter_lab_config.py"
	while IFS='|' read -r src dest; do
		[ -n "${src}" ] || continue
		link_jupyter_lab_setting "${src}" "${dest}"
	done <<'EOF'
apputils/notification.jsonc|@jupyterlab/apputils-extension/notification.jupyterlab-settings
apputils/themes.jsonc|@jupyterlab/apputils-extension/themes.jupyterlab-settings
codemirror/plugin.jsonc|@jupyterlab/codemirror-extension/plugin.jupyterlab-settings
completer/manager.jsonc|@jupyterlab/completer-extension/manager.jupyterlab-settings
console/tracker.jsonc|@jupyterlab/console-extension/tracker.jupyterlab-settings
docmanager/plugin.jsonc|@jupyterlab/docmanager-extension/plugin.jupyterlab-settings
filebrowser/browser.jsonc|@jupyterlab/filebrowser-extension/browser.jupyterlab-settings
fileeditor/plugin.jsonc|@jupyterlab/fileeditor-extension/plugin.jupyterlab-settings
jupyterlab_code_formatter/settings.jsonc|jupyterlab_code_formatter/settings.jupyterlab-settings
notebook/tracker.jsonc|@jupyterlab/notebook-extension/tracker.jupyterlab-settings
shortcuts/shortcuts.jsonc|@jupyterlab/shortcuts-extension/shortcuts.jupyterlab-settings
EOF
}

setup_static_configs() {
	log "Setting up static configs..."
	while IFS='|' read -r src dest; do
		[ -n "${src}" ] || continue
		link_config "${configs}/${src}" "${dest}"
	done <<'EOF'
bottom.toml|bottom/bottom.toml
direnv.toml|direnv/direnv.toml
fdignore|fd/ignore
git/ignore|git/ignore
pgcli.config|pgcli/config
ripgreprc|ripgrep/ripgreprc
starship.toml|starship.toml
wezterm.lua|wezterm/wezterm.lua
EOF
	setup_git_config
	setup_ipython_configs
	setup_jupyter_configs
	link_home "${configs}/psqlrc" .psqlrc
	link_home "${configs}/vimrc" .vimrc
	setup_vim_plugins
}

setup_tmux() {
	log "Setting up 'tmux'..."
	tmux_dir="${xdg_config_home}/tmux"
	tmux_repo="${tmux_dir}/.tmux"
	mkdir -p "${tmux_dir}"
	if [ ! -d "${tmux_repo}" ]; then
		if [ -e "${tmux_repo}" ] || [ -L "${tmux_repo}" ]; then
			fail "'${tmux_repo}' exists but is not a directory"
		fi
		if ! tmp_clone=$(mktemp -d "${tmux_dir}/.tmux.XXXXXX"); then
			fail "Could not create a temporary tmux checkout"
		fi
		if git clone https://github.com/gpakosz/.tmux.git "${tmp_clone}"; then
			if [ ! -f "${tmp_clone}/.tmux.conf" ]; then
				rm -rf -- "${tmp_clone}"
				fail "The tmux repository does not contain .tmux.conf"
			fi
			if ! mv -- "${tmp_clone}" "${tmux_repo}"; then
				rm -rf -- "${tmp_clone}"
				fail "Could not activate the tmux configuration"
			fi
		else
			clone_status=$?
			if ! rm -rf -- "${tmp_clone}"; then
				log "Warning: could not remove incomplete tmux checkout ${tmp_clone}" >&2
			fi
			return "${clone_status}"
		fi
	fi
	if [ ! -f "${tmux_repo}/.tmux.conf" ]; then
		fail "The existing tmux checkout is missing .tmux.conf"
	fi
	link_direct "${tmux_repo}/.tmux.conf" "${tmux_dir}/tmux.conf"
	link_config "${configs}/tmux.conf" tmux/tmux.conf.local
}

remove_legacy_files() {
	rm -f -- \
		"${HOME}/.pdbrc" \
		"${HOME}/.viminfo" \
		"${HOME}/.zshrc"
	rm -rf -- \
		"${xdg_config_home}/fish" \
		"${xdg_config_home}/ghostty" \
		"${xdg_config_home}/nvim" \
		"${xdg_config_home}/posix" \
		"${xdg_config_home}/pudb" \
		"${xdg_config_home}/stayfocusd" \
		"${xdg_config_home}/zsh"
}

setup_hostname() {
	[ "${platform}" = mac ] || return 0
	case "${machine:-}" in
	rh_mac_mini)
		new_hostname=RH-MacMini
		;;
	dw_mac_mini)
		new_hostname=DW-MacMini
		;;
	dw_macbook_neo)
		new_hostname=DW-MacBookNeo
		;;
	*)
		return 0
		;;
	esac
	current=$(scutil --get ComputerName 2>/dev/null || true)
	[ "${current}" = "${new_hostname}" ] && return 0
	log "Setting hostname to '${new_hostname}'..."
	acquire_sudo
	sudo scutil --set ComputerName "${new_hostname}"
	sudo scutil --set HostName "${new_hostname}"
	sudo scutil --set LocalHostName "${new_hostname}"
	sudo dscacheutil -flushcache
}

setup_brew_services() {
	[ "${platform}" = mac ] || return 0
	brew services start postgresql@18
	brew services start redis
}

setup_all() {
	log "Setting up '$(hostname)'..."
	setup_bash
	setup_ssh
	setup_brew_services
	setup_macos_defaults
	setup_tailscale
	setup_static_configs
	setup_tmux
	remove_legacy_files
	case "${platform}" in
	linux)
		setup_keymapp
		;;
	esac
}

#### parse arguments ##########################################################

dotfiles_default="${HOME}/dotfiles"
dotfiles=''
configs=''
xdg_config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
repo="${DOTFILES_REPO:-https://github.com/dycw/dotfiles.git}"
local_user=''
target=''
port=''

show_usage_and_exit() {
	cat <<'EOF' >&2

Usage:
  setup.sh
  setup.sh --user username
  setup.sh --ssh user@host [--port 222]

Notes:
  - No args: setup current user locally.
  - --user: runs the setup as another local user.
  - --ssh: runs the setup remotely over SSH.
EOF
	exit 1
}

if [ "${_SETUP_MAIN:-1}" -ne 0 ]; then
	while [ $# -gt 0 ]; do
		case "$1" in
		--user=*)
			local_user=${1#--user=}
			if [ -z "${local_user}" ]; then
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] Empty '--user'; exiting..." >&2
				show_usage_and_exit
			fi
			shift
			;;
		--user)
			if [ $# -le 1 ]; then
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] '--user' requires an argument; exiting..." >&2
				show_usage_and_exit
			fi
			local_user=$2
			shift 2
			;;
		--ssh=*)
			target=${1#--ssh=}
			if [ -z "${target}" ]; then
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] Empty '--ssh'; exiting..." >&2
				show_usage_and_exit
			fi
			shift
			;;
		--ssh)
			if [ $# -le 1 ]; then
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] '--ssh' requires an argument; exiting..." >&2
				show_usage_and_exit
			fi
			target=$2
			shift 2
			;;
		--port=*)
			port=${1#--port=}
			if [ -z "${port}" ]; then
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] Empty '--port'; exiting..." >&2
				show_usage_and_exit
			fi
			shift
			;;
		--port)
			if [ $# -le 1 ]; then
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] '--port' requires an argument; exiting..." >&2
				show_usage_and_exit
			fi
			port=$2
			shift 2
			;;
		-h | --help)
			show_usage_and_exit
			;;
		*)
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] Unsupported argument '$1'; exiting..." >&2
			show_usage_and_exit
			;;
		esac
	done

	if [ -n "${local_user}" ] && [ -n "${target}" ]; then
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] Mutually exclusive arguments '--user' and '--ssh' were given; exiting..." >&2
		show_usage_and_exit
	fi
fi

#### run local self ###########################################################

ensure_git() {
	if git --version >/dev/null 2>&1; then
		return
	fi

	log "Installing 'git'..."
	case "$(uname)" in
	Linux)
		if [ ! -r /etc/os-release ]; then
			fail "'/etc/os-release' is not readable; exiting..."
		fi
		. /etc/os-release
		if [ "${ID:-}" != debian ]; then
			fail "Unsupported Linux distribution '${ID:-unknown}'; exiting..."
		fi
		run_root apt-get -o DPkg::Lock::Timeout=300 update
		run_root apt-get -o DPkg::Lock::Timeout=300 install -y git
		;;
	Darwin)
		if ! command -v brew >/dev/null 2>&1; then
			log "Installing 'brew'..."
			acquire_sudo
			if ! run_script_from_url https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh env NONINTERACTIVE=1 HOMEBREW_NO_ENV_HINTS=1 /bin/bash -s; then
				fail "'brew' installation failed"
			fi
			log "'brew' installed successfully"
		fi
		if [ -x /opt/homebrew/bin/brew ]; then
			export PATH="/opt/homebrew/bin${PATH:+:${PATH}}"
		elif [ -x /usr/local/bin/brew ]; then
			export PATH="/usr/local/bin${PATH:+:${PATH}}"
		fi
		brew install git
		;;
	*)
		fail "Unsupported OS '$(uname)'; exiting..."
		;;
	esac
}

resolve_dotfiles() {
	if [ -f "${self_path}" ] && [ -d "${self_dir}/.git" ]; then
		dotfiles=${self_dir}
	else
		dotfiles=${dotfiles_default}
	fi
	configs="${dotfiles}/configs"
}

run_local_self() {
	log "Setting up '$(hostname)'..."

	resolve_dotfiles
	determine_platform
	if [ "$(id -u)" -eq 0 ]; then
		fail "Run setup.sh as the user to configure, or use --user USER as root"
	fi
	ensure_git

	if [ -d "${dotfiles}/.git" ]; then
		log "Updating repo..."
		git -C "${dotfiles}" fetch origin
		git -C "${dotfiles}" reset --hard origin/master
	else
		if [ -e "${dotfiles}" ] || [ -L "${dotfiles}" ]; then
			fail "'${dotfiles}' exists but is not a git repository; refusing to replace it"
		fi
		log "Cloning repo..."
		if ! clone_tmp=$(mktemp -d "${dotfiles}.clone.XXXXXX"); then
			fail "Could not create a temporary clone directory"
		fi
		if git clone "${repo}" "${clone_tmp}"; then
			if ! mv -- "${clone_tmp}" "${dotfiles}"; then
				rm -rf -- "${clone_tmp}"
				fail "Could not activate the cloned repository at ${dotfiles}"
			fi
		else
			clone_status=$?
			if ! rm -rf -- "${clone_tmp}"; then
				log "Warning: could not remove incomplete clone ${clone_tmp}" >&2
			fi
			return "${clone_status}"
		fi
		configs="${dotfiles}/configs"
	fi

	setup_hostname
	install_all
	setup_all
}

#### run local other ##########################################################

run_local_other() {
	user="$1"
	log "Setting up '${user}' on '$(hostname)'..."

	tmp=$(mktemp "${TMPDIR:-/tmp}/setup.XXXXXX")
	trap 'rm -f -- "${tmp}"' EXIT HUP INT TERM
	cp -- "${self_path}" "${tmp}"
	chmod 0755 "${tmp}"
	su - "${user}" -c "sh '${tmp}'"
}

#### run remote ###############################################################

run_remote() {
	target=$1
	port=${2:-22}
	log "Setting up '${target}'..."
	ssh -p "${port}" "${target}" 'set -eu
	tmp=$(mktemp "${TMPDIR:-/tmp}/setup.XXXXXX")
	trap '\''rm -f -- "$tmp"'\'' EXIT HUP INT TERM
	cat >"$tmp"
	chmod 0755 "$tmp"
	sh "$tmp"' <"${self_path}"
}

#### main #####################################################################

if [ "${_SETUP_MAIN:-1}" -ne 0 ]; then
	if [ -n "${local_user}" ]; then
		run_local_other "${local_user}"
	elif [ -n "${target}" ]; then
		run_remote "${target}" "${port}"
	else
		run_local_self
	fi
fi

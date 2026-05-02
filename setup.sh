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
brew() { command brew "$@" </dev/null; }

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

fail() {
	log "$*" >&2
	exit 1
}

_sudo_acquired=0

acquire_sudo() {
	[ "${_sudo_acquired}" -eq 1 ] && return
	if ! sudo -n true 2>/dev/null; then
		log "Requesting sudo access..."
		sudo -v
	fi
	_sudo_acquired=1
	while true; do
		sudo -n true 2>/dev/null || true
		sleep 60
		kill -0 "$$" 2>/dev/null || exit 0
	done &
}

run_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	else
		acquire_sudo
		sudo "$@"
	fi
}

add_brew_to_path() {
	if [ -x /opt/homebrew/bin/brew ]; then
		export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH:+:${PATH}}"
	elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
		export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH:+:${PATH}}"
	elif [ -x /usr/local/bin/brew ]; then
		export PATH="/usr/local/bin:/usr/local/sbin${PATH:+:${PATH}}"
	fi
}

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
		;;
	Darwin)
		platform=mac
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
	mkdir -p "$(dirname -- "${HOME}/${dest}")"
	ln -sfn "${src}" "${HOME}/${dest}"
}

link_config() {
	src=$1
	dest=$2
	mkdir -p "$(dirname -- "${xdg_config_home}/${dest}")"
	ln -sfn "${src}" "${xdg_config_home}/${dest}"
}

link_direct() {
	src=$1
	dest=$2
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
	if ! grep -Fqx "${line}" "${path}"; then
		printf '\n%s\n' "${line}" >>"${path}"
	fi
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
	if command -v brew >/dev/null 2>&1; then
		return
	fi
	if [ "${platform}" = linux ]; then
		log "Installing Linux brew prerequisites..."
		run_root apt-get update
		run_root apt-get install -y build-essential curl file git procps sudo
	fi
	log "Installing 'brew'..."
	acquire_sudo
	NONINTERACTIVE=1 HOMEBREW_NO_ENV_HINTS=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	add_brew_to_path
	command -v brew >/dev/null 2>&1 || fail "'brew' installation failed"
	log "'brew' installed successfully"
}

brew_formula_installed() {
	brew list --formula "$1" >/dev/null 2>&1
}

brew_cask_installed() {
	brew list --cask "$1" >/dev/null 2>&1
}

parallel_install_apt_packages() {
	tmp=$(mktemp -d)
	i=0
	for package in "$@"; do
		(dpkg -s "${package}" >/dev/null 2>&1 || printf '%s\n' "${package}" >"${tmp}/${i}") &
		i=$((i + 1))
	done
	wait
	missing=$(cat "${tmp}"/* 2>/dev/null | sort -u || true)
	rm -rf -- "${tmp}"
	[ -n "${missing}" ] || return 0
	log "Installing packages: ${missing}"
	run_root apt-get install -y ${missing}
}

# Checks all given formulae in parallel, then uninstalls any present ones.
parallel_uninstall_brew_formulas() {
	tmp=$(mktemp -d)
	i=0
	for formula in "$@"; do
		(if brew_formula_installed "${formula}"; then printf '%s\n' "${formula}" >"${tmp}/${i}"; fi) &
		i=$((i + 1))
	done
	wait
	present=$(cat "${tmp}"/* 2>/dev/null | sort -u || true)
	rm -rf -- "${tmp}"
	[ -n "${present}" ] || return 0
	log "Uninstalling formulae: ${present}"
	brew uninstall ${present}
}

# Checks all given casks in parallel, then uninstalls any present ones.
parallel_uninstall_brew_casks() {
	tmp=$(mktemp -d)
	i=0
	for cask in "$@"; do
		(if brew_cask_installed "${cask}"; then printf '%s\n' "${cask}" >"${tmp}/${i}"; fi) &
		i=$((i + 1))
	done
	wait
	present=$(cat "${tmp}"/* 2>/dev/null | sort -u || true)
	rm -rf -- "${tmp}"
	[ -n "${present}" ] || return 0
	log "Uninstalling casks: ${present}"
	brew uninstall --cask ${present}
}

# Checks all given formulae in parallel, then installs any missing ones in a
# single brew call.
parallel_install_brew_formulas() {
	tmp=$(mktemp -d)
	i=0
	for formula in "$@"; do
		(brew_formula_installed "${formula}" || printf '%s\n' "${formula}" >"${tmp}/${i}") &
		i=$((i + 1))
	done
	wait
	missing=$(cat "${tmp}"/* 2>/dev/null | sort -u || true)
	rm -rf -- "${tmp}"
	[ -n "${missing}" ] || return 0
	log "Installing formulae: ${missing}"
	brew install ${missing}
}

# Checks all given casks in parallel, then installs any missing ones in a
# single brew call. Uses --adopt to handle apps installed outside Homebrew.
parallel_install_brew_casks() {
	tmp=$(mktemp -d)
	i=0
	for cask in "$@"; do
		(brew_cask_installed "${cask}" || printf '%s\n' "${cask}" >"${tmp}/${i}") &
		i=$((i + 1))
	done
	wait
	missing=$(cat "${tmp}"/* 2>/dev/null | sort -u || true)
	rm -rf -- "${tmp}"
	[ -n "${missing}" ] || return 0
	log "Installing casks: ${missing}"
	brew install --cask --adopt ${missing}
}

maybe_upgrade_brew_formulas() {
	[ "${should_upgrade:-0}" -eq 1 ] || return 0
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
	run_root apt-get upgrade -y
}

maybe_upgrade_rust() {
	[ "${should_upgrade:-0}" -eq 1 ] || return 0
	log "Updating rust toolchain and cargo tools..."
	rustup update
	for tool in bacon cargo-audit cargo-deny cargo-edit cargo-nextest sccache; do
		cargo binstall -y --force "${tool}" &
	done
	wait
}

#### packages #################################################################

remove_unwanted_brew_formulas() {
	parallel_uninstall_brew_formulas age sops rlwrap yoannfleurydev/gitweb/gitweb
}

install_common_brew_formulas() {
	parallel_install_brew_formulas \
		asciinema autoconf automake bat bottom coreutils delta \
		direnv dust eza fd fzf gh git-delta iperf3 jq just libpq \
		luacheck luarocks markdownlint-cli maturin npm pgcli postgresql@18 prettier redis \
		rename restic ripgrep ruff sd shellcheck shfmt starship \
		taplo tmux topgrade uv vim watch yq zoxide

	if [ "${platform}" = mac ]; then
		parallel_install_brew_formulas agg bash-completion@2 dnsmasq flock mas tailscale
	fi
}

install_linux_packages() {
	parallel_install_apt_packages curl rsync sudo xclip xsel
}

install_tailscale_linux() {
	if command -v tailscale >/dev/null 2>&1; then
		return 0
	fi
	log "Installing tailscale via upstream script..."
	acquire_sudo
	curl -fsSL https://tailscale.com/install.sh | sh
}

remove_unwanted_brew_casks() {
	parallel_uninstall_brew_casks \
		db-browser-for-sqlite firefox ghostty google-chrome iterm2 pgadmin4 slack
}

ensure_brew_taps() {
	brew tap redis-stack/redis-stack
}

install_mac_casks() {
	ensure_brew_taps
	parallel_install_brew_casks \
		1password a-better-finder-attributes a-better-finder-rename \
		chatgpt docker dropbox handy postico protonvpn redis-stack spotify telegram \
		transmission vlc wezterm whatsapp zoom
}

# 1Password for Safari (App Store id 1569813296)
mac_app_store_apps='1569813296'

parallel_install_mas_apps() {
	tmp=$(mktemp -d)
	i=0
	for app_id in "$@"; do
		(mas list 2>/dev/null | awk '{print $1}' | grep -Fxq "${app_id}" || printf '%s\n' "${app_id}" >"${tmp}/${i}") &
		i=$((i + 1))
	done
	wait
	missing=$(cat "${tmp}"/* 2>/dev/null | sort -u || true)
	rm -rf -- "${tmp}"
	[ -n "${missing}" ] || return 0
	log "Installing Mac App Store apps: ${missing}"
	for app_id in ${missing}; do
		mas install "${app_id}" || log "Warning: failed to install App Store app ${app_id}; sign in to the App Store and re-run"
	done
}

install_mac_app_store_apps() {
	command -v mas >/dev/null 2>&1 || return 0
	# shellcheck disable=SC2086
	parallel_install_mas_apps ${mac_app_store_apps}
}

maybe_upgrade_mas_apps() {
	[ "${should_upgrade:-0}" -eq 1 ] || return 0
	command -v mas >/dev/null 2>&1 || return 0
	log "Upgrading Mac App Store apps..."
	mas upgrade || log "Warning: 'mas upgrade' failed; sign in to the App Store and re-run"
}

install_rust_tools() {
	if command -v rustup >/dev/null 2>&1; then
		log "'rust' is already installed"
	else
		log "Installing 'rust'..."
		curl -LsSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
		. "${HOME}/.cargo/env"
		rustup toolchain install stable
		rustup default stable
		rustup component add clippy rust-analyzer rust-docs rustfmt
		rustup target add x86_64-unknown-linux-gnu x86_64-apple-darwin aarch64-apple-darwin
	fi

	if command -v cargo-binstall >/dev/null 2>&1; then
		log "'cargo-binstall' is already installed"
	else
		log "Installing 'cargo-binstall'..."
		curl -L --proto '=https' --tlsv1.2 -sSf \
			https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
	fi

	for tool in bacon cargo-audit cargo-deny cargo-edit cargo-nextest sccache; do
		if command -v "${tool}" >/dev/null 2>&1; then
			log "'${tool}' is already installed"
		else
			log "Installing '${tool}' using 'cargo binstall'..."
			if ! cargo binstall -y "${tool}"; then
				log "Installing '${tool}' using 'cargo install'..."
				cargo install --locked "${tool}"
			fi
		fi
	done
}

install_keymapp() {
	log "Installing 'keymapp'..."
	tmp=$(mktemp -d)
	trap 'rm -rf -- "${tmp}"' EXIT HUP INT TERM
	url='https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz'
	curl -fsSL "${url}" | tar -xz -C "${tmp}"
	install -Dm755 "${tmp}/keymapp" "${HOME}/.local/bin/keymapp"
}

install_all() {
	log "Installing apps on '$(hostname)'..."

	should_upgrade=0
	if should_upgrade; then
		should_upgrade=1
		log "Upgrade timer expired; will refresh installed packages"
	fi

	ensure_brew
	remove_unwanted_brew_formulas
	install_common_brew_formulas
	maybe_upgrade_brew_formulas
	install_rust_tools
	maybe_upgrade_rust
	if [ "${platform}" = linux ]; then
		install_linux_packages
		maybe_upgrade_apt_packages
		install_tailscale_linux
		install_keymapp
	else
		remove_unwanted_brew_casks
		install_mac_casks
		maybe_upgrade_brew_casks
		install_mac_app_store_apps
		maybe_upgrade_mas_apps
	fi

	if [ "${should_upgrade}" -eq 1 ]; then
		mark_upgraded
	fi
}

#### setup ####################################################################

setup_ssh() {
	log "Setting up 'ssh'..."
	mkdir -p "${HOME}/.ssh"
	chmod 700 "${HOME}/.ssh"

	cp -- "${configs}/authorized_keys" "${HOME}/.ssh/authorized_keys"
	chmod 600 "${HOME}/.ssh/authorized_keys"

	mkdir -p "${HOME}/.ssh/config.d"
	chmod 700 "${HOME}/.ssh/config.d"
	ensure_line_in_file 'Include ~/.ssh/config.d/*' "${HOME}/.ssh/config"
	chmod 600 "${HOME}/.ssh/config"

	if [ "${platform:-}" = mac ] && ! nc -z 127.0.0.1 22 2>/dev/null; then
		run_root launchctl enable system/com.openssh.sshd
	fi
}

setup_bash() {
	log "Setting up 'bash'..."
	link_home "${configs}/bash/bashrc" .bashrc
	link_home "${configs}/bash/bash_profile" .bash_profile
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
}

setup_tailscale() {
	command -v tailscale >/dev/null 2>&1 || return 0

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
	if [ "${platform}" = mac ]; then
		run_root brew services restart tailscale
	else
		run_root systemctl enable --now tailscaled
	fi

	if [ -z "${TAILSCALE_LOGIN_SERVER:-}" ] || [ -z "${TAILSCALE_AUTH_KEY:-}" ]; then
		log "TAILSCALE_LOGIN_SERVER or TAILSCALE_AUTH_KEY not set; skipping 'tailscale up'"
		return 0
	fi

	# `tailscale status` (no flag) errors with "Logged out." until BackendState
	# is Running, so on a fresh daemon it never succeeds. `--json` returns the
	# status object as long as the local API is reachable.
	log "Waiting for tailscaled to be ready..."
	i=0
	while ! run_root tailscale status --json >/dev/null 2>&1; do
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
	# DNS is handled by the local dnsmasq (see setup_dnsmasq_mac); the
	# brew tailscale formula on macOS cannot register a working scutil
	# resolver anyway.
	run_root tailscale up \
		--accept-dns=false --accept-routes \
		--auth-key "${TAILSCALE_AUTH_KEY}" \
		--hostname "${ts_hostname}" \
		--login-server "${TAILSCALE_LOGIN_SERVER}" \
		--reset \
		--timeout=30s
}

setup_dnsmasq_mac() {
	[ "${platform}" = mac ] || return 0
	command -v dnsmasq >/dev/null 2>&1 || return 0

	conf_dir=/opt/homebrew/etc/dnsmasq.d
	conf_file="${conf_dir}/qrt.conf"
	main_conf=/opt/homebrew/etc/dnsmasq.conf

	mkdir -p -- "${conf_dir}"

	# Symlink so repo updates are reflected without re-running setup.sh.
	# Only (re)create the symlink — and restart dnsmasq — when the target
	# has changed; readlink needs no sudo.
	if [ "$(readlink "${conf_file}" 2>/dev/null)" != "${configs}/dnsmasq.conf" ]; then
		log "Symlinking dnsmasq config '${conf_file}'..."
		ln -sf "${configs}/dnsmasq.conf" "${conf_file}"
		if ! grep -q '^conf-dir=' "${main_conf}" 2>/dev/null; then
			printf 'conf-dir=%s/,*.conf\n' "${conf_dir}" |
				run_root tee -a "${main_conf}" >/dev/null
		fi
		run_root brew services restart dnsmasq
	fi

	# Point every enabled network service at the local dnsmasq only if not
	# already set — avoids sudo on re-runs. The first line of
	# -listallnetworkservices is a header; disabled services start with '*'.
	dns_changed=0
	tmp=$(mktemp)
	networksetup -listallnetworkservices | tail -n +2 >"${tmp}"
	while IFS= read -r svc; do
		case "${svc}" in
		\**) continue ;;
		esac
		if ! networksetup -getdnsservers "${svc}" 2>/dev/null | grep -qx '127\.0\.0\.1'; then
			log "Pointing '${svc}' DNS at 127.0.0.1..."
			run_root networksetup -setdnsservers "${svc}" 127.0.0.1
			dns_changed=1
		fi
	done <"${tmp}"
	rm -f -- "${tmp}"

	if [ "${dns_changed}" -eq 1 ]; then
		run_root dscacheutil -flushcache
		run_root killall -HUP mDNSResponder
	fi
}

setup_env_sh() {
	log "Setting up /etc/profile.d/env.sh..."
	if ! cmp -s "${configs}/sh/env.sh" /etc/profile.d/env.sh 2>/dev/null; then
		run_root mkdir -p /etc/profile.d
		run_root cp -- "${configs}/sh/env.sh" /etc/profile.d/env.sh
		run_root chmod 644 /etc/profile.d/env.sh
	fi
	if [ "${platform}" = mac ]; then
		if ! cmp -s "${configs}/sh/profile" /etc/profile 2>/dev/null; then
			log "Overwriting /etc/profile to add /etc/profile.d support..."
			run_root cp -- "${configs}/sh/profile" /etc/profile
		fi
	fi
}

setup_keymapp() {
	log "Setting up 'keymapp'..."
	link_direct "${configs}/keymapp.50-zsa.rules" /etc/udev/rules.d/50-zsa.rules
}

setup_static_configs() {
	log "Setting up static configs..."
	link_config "${configs}/bottom.toml" bottom/bottom.toml
	link_config "${configs}/direnv.toml" direnv/direnv.toml
	link_config "${configs}/fdignore" fd/ignore
	link_config "${configs}/git/config" git/config
	link_config "${configs}/git/ignore" git/ignore
	link_config "${configs}/pgcli.config" pgcli/config
	link_config "${configs}/ripgreprc" ripgrep/ripgreprc
	link_config "${configs}/starship.toml" starship.toml
	link_config "${configs}/wezterm.lua" wezterm/wezterm.lua
	link_direct "${configs}/ipython/ipython_config.py" "${HOME}/.ipython/profile_default/ipython_config.py"
	link_direct "${configs}/ipython/startup.py" "${HOME}/.ipython/profile_default/startup/startup.py"
	link_direct "${configs}/jupyter/jupyter_lab_config.py" "${xdg_config_home}/jupyter/jupyter_lab_config.py"
	link_direct "${configs}/jupyter/apputils/notification.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings"
	link_direct "${configs}/jupyter/apputils/themes.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings"
	link_direct "${configs}/jupyter/codemirror/plugin.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/codemirror-extension/plugin.jupyterlab-settings"
	link_direct "${configs}/jupyter/completer/manager.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/completer-extension/manager.jupyterlab-settings"
	link_direct "${configs}/jupyter/console/tracker.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/console-extension/tracker.jupyterlab-settings"
	link_direct "${configs}/jupyter/docmanager/plugin.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/docmanager-extension/plugin.jupyterlab-settings"
	link_direct "${configs}/jupyter/filebrowser/browser.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/filebrowser-extension/browser.jupyterlab-settings"
	link_direct "${configs}/jupyter/fileeditor/plugin.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/fileeditor-extension/plugin.jupyterlab-settings"
	link_direct "${configs}/jupyter/jupyterlab_code_formatter/settings.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/jupyterlab_code_formatter/settings.jupyterlab-settings"
	link_direct "${configs}/jupyter/notebook/tracker.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings"
	link_direct "${configs}/jupyter/shortcuts/shortcuts.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/shortcuts.jupyterlab-settings"
	link_home "${configs}/psqlrc" .psqlrc
	link_home "${configs}/vimrc" .vimrc
}

setup_tmux() {
	log "Setting up 'tmux'..."
	tmux_dir="${xdg_config_home}/tmux"
	mkdir -p "${tmux_dir}"
	if [ ! -d "${tmux_dir}/.tmux" ]; then
		git clone https://github.com/gpakosz/.tmux.git "${tmux_dir}/.tmux"
	fi
	link_direct "${tmux_dir}/.tmux/.tmux.conf" "${tmux_dir}/tmux.conf"
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
	rm -f -- \
		/opt/homebrew/etc/dnsmasq.d/mac-derek.conf \
		/opt/homebrew/etc/dnsmasq.d/dnsmasq.conf
}

setup_hostname() {
	[ "${platform}" = mac ] || return 0
	model=$(sysctl -n hw.model 2>/dev/null || true)
	case "${model}" in
	Mac14,3)
		new_hostname=RH-MacMini
		;;
	Mac14,12)
		new_hostname=DW-MacMini
		;;
	MacBook*)
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
	# dnsmasq binds port 53 (privileged). Skip if already running so re-runs
	# don't prompt for sudo unnecessarily.
	if ! pgrep -x dnsmasq >/dev/null 2>&1; then
		run_root brew services start dnsmasq
	fi
	if ! pgrep -x tailscaled >/dev/null 2>&1; then
		run_root brew services start tailscale
	fi
	brew services start postgresql@18
	brew services start redis
}

setup_all() {
	log "Setting up '$(hostname)'..."
	setup_bash
	setup_ssh
	setup_brew_services
	setup_dnsmasq_mac
	setup_tailscale
	setup_env_sh
	setup_static_configs
	setup_tmux
	remove_legacy_files
	if [ "${platform}" = linux ]; then
		setup_keymapp
	fi
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
		if [ "$(id -u)" -eq 0 ]; then
			apt-get update
			apt-get install -y git
		else
			sudo apt-get update
			sudo apt-get install -y git
		fi
		;;
	Darwin)
		if ! command -v brew >/dev/null 2>&1; then
			log "Installing 'brew'..."
			acquire_sudo
			NONINTERACTIVE=1 HOMEBREW_NO_ENV_HINTS=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
	if [ -d "${self_dir}/.git" ]; then
		dotfiles=${self_dir}
	else
		dotfiles=${dotfiles_default}
	fi
	configs="${dotfiles}/configs"
}

run_local_self() {
	log "Setting up '$(hostname)'..."

	resolve_dotfiles
	ensure_git

	if [ -d "${dotfiles}/.git" ]; then
		log "Updating repo..."
		git -C "${dotfiles}" fetch origin
		git -C "${dotfiles}" reset --hard origin/master
	else
		log "Cloning repo..."
		git clone "${repo}" "${dotfiles}"
		configs="${dotfiles}/configs"
	fi

	determine_platform
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

	tmp=$(
		ssh -p "${port}" "${target}" /bin/sh -s <<'EOF'
set -eu
mktemp "${TMPDIR:-/tmp}/setup.XXXXXX"
EOF
	)
	tmp=$(printf '%s' "${tmp}") # trailing slash
	ssh -p "${port}" "${target}" "cat > '${tmp}'" <"${self_path}"
	ssh -p "${port}" "${target}" /bin/sh -s "${tmp}" <<'EOF'
set -eu
chmod 0755 "$1"
sh "$1"
rm -f -- "$1"
EOF
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

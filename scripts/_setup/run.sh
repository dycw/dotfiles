#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2034,SC2154

set -eu

case "$0" in
/*) _setup_self_path=$0 ;;
*) _setup_self_path=$(pwd -P)/$0 ;;
esac
script_dir=$(CDPATH='' cd -- "$(dirname -- "${_setup_self_path}")" && pwd -P)
repo_root=$(CDPATH='' cd -- "${script_dir}/../.." && pwd -P)
configs="${repo_root}/configs"
xdg_config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"

#### utilities ################################################################

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

fail() {
	log "$*" >&2
	exit 1
}

run_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	else
		sudo "$@"
	fi
}

add_brew_to_path() {
	if [ -x /opt/homebrew/bin/brew ]; then
		export PATH="/opt/homebrew/bin${PATH:+:${PATH}}"
	elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
		export PATH="/home/linuxbrew/.linuxbrew/bin${PATH:+:${PATH}}"
	elif [ -x /usr/local/bin/brew ]; then
		export PATH="/usr/local/bin${PATH:+:${PATH}}"
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

#### install ##################################################################

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
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	add_brew_to_path
	command -v brew >/dev/null 2>&1 || fail "'brew' installation failed"
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
	# shellcheck disable=SC2086
	run_root apt-get install -y ${missing}
}

uninstall_brew_formula() {
	formula=$1
	if ! brew_formula_installed "${formula}"; then
		return
	fi
	log "Uninstalling '${formula}'..."
	brew uninstall "${formula}"
}

remove_unwanted_brew_formulas() {
	for formula in age sops rlwrap yoannfleurydev/gitweb/gitweb; do
		uninstall_brew_formula "${formula}"
	done
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
	# shellcheck disable=SC2086
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
	# shellcheck disable=SC2086
	brew install --cask --adopt ${missing}
}

install_common_brew_formulas() {
	parallel_install_brew_formulas \
		asciinema autoconf automake bat bottom coreutils delta \
		direnv dust eza fd fzf gh git-delta iperf3 jq just libpq \
		luacheck luarocks maturin npm pgcli postgresql@18 prettier redis \
		rename restic ripgrep ruff sd shellcheck shfmt starship \
		tailscale tmux topgrade uv vim watch yq zoxide

	if [ "${platform}" = mac ]; then
		parallel_install_brew_formulas agg dnsmasq flock
	fi
}

install_linux_packages() {
	parallel_install_apt_packages curl rsync sudo xclip xsel
}

install_mac_casks() {
	parallel_install_brew_casks \
		1password db-browser-for-sqlite dropbox ghostty pgadmin4 postico \
		protonvpn redis-stack spotify transmission vlc wezterm whatsapp zoom
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

install_all() {
	log "Installing apps on '$(hostname)'..."
	ensure_brew
	remove_unwanted_brew_formulas
	install_common_brew_formulas
	install_rust_tools
	if [ "${platform}" = linux ]; then
		install_linux_packages
	else
		install_mac_casks
	fi
}

#### setup ####################################################################

setup_ssh() {
	log "Setting up 'ssh'..."
	mkdir -p "${HOME}/.ssh"
	chmod 700 "${HOME}/.ssh"

	if [ ! -f "${HOME}/.ssh/authorized_keys" ]; then
		authorized_keys_url='https://raw.githubusercontent.com/dycw/authorized-keys/refs/heads/master/authorized_keys'
		curl -fssL "${authorized_keys_url}" >"${HOME}/.ssh/authorized_keys"
		chmod 600 "${HOME}/.ssh/authorized_keys"
	fi

	mkdir -p "${HOME}/.ssh/config.d"
	chmod 700 "${HOME}/.ssh/config.d"
	ensure_line_in_file 'Include ~/.ssh/config.d/*' "${HOME}/.ssh/config"
	chmod 600 "${HOME}/.ssh/config"
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
			if [ -t 0 ]; then
				chsh -s "${bash_path}" || true
			else
				log "'bash' is not the default shell; run \"chsh -s '${bash_path}'\""
			fi
		fi
	fi
}

setup_shell_hooks() {
	log "Setting up shell hooks..."
	posix_dir="${xdg_config_home}/posix"
	mkdir -p "${posix_dir}"
	find "${configs}" -maxdepth 1 -type f -name '*.sh' | sort | while IFS= read -r script; do
		name=$(basename -- "${script}")
		ln -sfn "${script}" "${posix_dir}/${name}"
	done
}

setup_static_configs() {
	log "Setting up static configs..."
	link_config "${configs}/bottom/bottom.toml" bottom/bottom.toml
	link_config "${configs}/direnv/direnv.toml" direnv/direnv.toml
	link_config "${configs}/fd/ignore" fd/ignore
	link_config "${configs}/git/config" git/config
	link_config "${configs}/git/ignore" git/ignore
	link_config "${configs}/pgcli/config" pgcli/config
	link_config "${configs}/ripgrep/ripgreprc" ripgrep/ripgreprc
	link_config "${configs}/starship/starship.toml" starship.toml
	link_config "${configs}/tmux/.tmux/.tmux.conf" tmux/tmux.conf
	link_config "${configs}/tmux/tmux.conf.local" tmux/tmux.conf.local
	link_config "${configs}/wezterm/wezterm.lua" wezterm/wezterm.lua
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
	link_home "${configs}/pdb/pdbrc" .pdbrc
	link_home "${configs}/psql/psqlrc" .psqlrc
	link_config "${configs}/pudb/pudb.cfg" pudb/pudb.cfg
}

setup_all() {
	log "Setting up '$(hostname)'..."
	setup_bash
	setup_ssh
	setup_shell_hooks
	setup_static_configs
	rm -rf -- "${xdg_config_home}/fish"
}

#### main #####################################################################

if [ "${_RUN_MAIN:-1}" -ne 0 ]; then
	determine_platform
	install_all
	setup_all
fi

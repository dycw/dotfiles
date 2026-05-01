#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2034,SC2086,SC2154

set -eu

case "$0" in
/*) self_path=$0 ;;
*) self_path=$(pwd -P)/$0 ;;
esac
self_dir=$(CDPATH='' cd -- "$(dirname -- "$self_path")" && pwd -P)

#### utilities ################################################################

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

remove_unwanted_brew_formulas() {
	parallel_uninstall_brew_formulas age sops rlwrap yoannfleurydev/gitweb/gitweb
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

install_common_brew_formulas() {
	parallel_install_brew_formulas \
		asciinema autoconf automake bat bottom coreutils delta \
		direnv dust eza fd fzf gh git-delta iperf3 jq just libpq \
		luacheck luarocks markdownlint-cli maturin npm pgcli postgresql@18 prettier redis \
		rename restic ripgrep ruff sd shellcheck shfmt starship \
		tailscale taplo tmux topgrade uv vim watch yq zoxide

	if [ "${platform}" = mac ]; then
		parallel_install_brew_formulas agg dnsmasq flock
	fi
}

install_linux_packages() {
	parallel_install_apt_packages curl rsync sudo xclip xsel
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
		chatgpt dropbox postico protonvpn redis-stack spotify telegram \
		transmission vlc wezterm whatsapp zoom
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
	ensure_brew
	remove_unwanted_brew_formulas
	install_common_brew_formulas
	install_rust_tools
	if [ "${platform}" = linux ]; then
		install_linux_packages
		install_keymapp
	else
		remove_unwanted_brew_casks
		install_mac_casks
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
			if [ -t 0 ]; then
				chsh -s "${bash_path}" || true
			else
				log "'bash' is not the default shell; run \"chsh -s '${bash_path}'\""
			fi
		fi
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

setup_all() {
	log "Setting up '$(hostname)'..."
	setup_bash
	setup_ssh
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

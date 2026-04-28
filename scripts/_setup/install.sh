#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$(realpath -- "$0")")/lib.sh"

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

install_brew_formula() {
	formula=$1
	if brew_formula_installed "${formula}"; then
		log "'${formula}' is already installed"
		return
	fi
	log "Installing '${formula}'..."
	brew install "${formula}"
}

install_brew_cask() {
	cask=$1
	if brew_cask_installed "${cask}"; then
		log "'${cask}' is already installed"
		return
	fi
	log "Installing '${cask}'..."
	brew install --cask "${cask}"
}

install_apt_package() {
	package=$1
	if dpkg -s "${package}" >/dev/null 2>&1; then
		log "'${package}' is already installed"
		return
	fi
	log "Installing '${package}'..."
	run_root apt-get install -y "${package}"
}

install_common_brew_formulas() {
	for formula in \
		age asciinema autoconf automake bat bottom coreutils delta \
		direnv dust eza fd fzf gh git-delta iperf3 jq just libpq \
		luacheck luarocks maturin npm pgcli postgresql@18 prettier redis \
		rename restic ripgrep rlwrap ruff sd shellcheck shfmt starship \
		tailscale tmux topgrade uv vim watch yq zoxide; do
		install_brew_formula "${formula}"
	done

	for formula in dnsmasq flock ggrep yoannfleurydev/gitweb/gitweb; do
		if [ "${platform}" = mac ]; then
			install_brew_formula "${formula}"
		fi
	done
}

install_linux_packages() {
	for package in curl rsync sudo xclip xsel; do
		install_apt_package "${package}"
	done
}

install_mac_casks() {
	for cask in \
		1password agg db-browser-for-sqlite dropbox ghostty pgadmin4 postico \
		protonvpn redis-stack spotify transmission vlc wezterm whatsapp zoom; do
		install_brew_cask "${cask}"
	done
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

main() {
	log "Installing apps on '$(hostname)'..."
	determine_platform
	ensure_brew
	install_common_brew_formulas
	install_rust_tools
	if [ "${platform}" = linux ]; then
		install_linux_packages
	else
		install_mac_casks
	fi
}

main

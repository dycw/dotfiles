#!/usr/bin/env sh
# shellcheck disable=SC1091

set -eu

###############################################################################

install_tool() {
	tool="$1"
	if command -v "${tool}" >/dev/null 2>&1; then
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] '${tool}' is already installed"
	else
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing '${tool}' using 'cargo binstall'..."
		if ! cargo binstall -y "${tool}"; then
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing '${tool}' using 'cargo install'..."
			cargo install --locked "${tool}"
		fi
	fi
}

###############################################################################

case "$1" in
debian | macmini)
	if command -v rustup >/dev/null 2>&1; then
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'rust' is already installed"
	else
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'rust'..."
		curl -LsSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
		. "$HOME/.cargo/env"
		rustup toolchain install stable
		rustup default stable
		rustup component add clippy rust-analyzer rust-docs rustfmt
		rustup target add x86_64-unknown-linux-gnu x86_64-apple-darwin aarch64-apple-darwin
	fi

	if command -v cargo-binstall >/dev/null 2>&1; then
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'cargo-binstall' is already installed"
	else
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'cargo-binstall'..."
		curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
		https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
	fi

	install_tool bacon
	install_tool cargo-audit
	install_tool cargo-deny
	install_tool cargo-edit
	install_tool cargo-nextest
	install_tool sccache
	;;
esac

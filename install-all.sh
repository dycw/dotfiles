#!/usr/bin/env sh

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2; }

# detect OS/Mac model
unset OS_NAME MAC_MODEL IS_MAC_MINI_DW IS_MAC_MINI_RH IS_MACBOOK DISTRO IS_UBUNTU
OS_NAME="$(uname)"
case "$OS_NAME" in
Darwin)
	MAC_MODEL=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')
	case "${MAC_MODEL}" in
	Mac14,12)
		echo_date "Detected DW Mac-Mini..."
		IS_MAC_MINI_DW=1
		;;
	Mac14,3)
		echo_date "Detected RH Mac-Mini..."
		IS_MAC_MINI_RH=1
		;;
	MacBook*)
		echo_date "Detected MacBook..."
		IS_MACBOOK=1
		;;
	*)
		echo_date "Unsupported Mac model: ${MAC_MODEL}"
		exit 1
		;;
	esac
	;;
Linux)
	DISTRO=$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2)
	case "${DISTRO}" in
	ubuntu)
		IS_UBUNTU=1
		echo_date "Detected Ubuntu..."
		;;
	*)
		echo_date "Unsupported Linux distrution: ${DISTRO}"
		exit 1
		;;
	esac
	;;
*)
	echo_date "Unsupported OS name: ${OS}"
	exit 1
	;;
esac

# groups
unset IS_MAC_MINI IS_MAC
if [ -n "${IS_MAC_MINI_DW}" ] || [ -n "${IS_MAC_MINI_RH}" ]; then
	IS_MAC_MINI=1
fi
if [ -n "${IS_MAC_MINI}" ] || [ -n "${IS_MACBOOK}" ]; then
	IS_MAC=1
fi

# machine - power management
set_pm_value() {
	__key=$1
	__value=$2
	__current=$(pmset -g custom | awk "/[[:space:]]${__key}[[:space:]]/ {print \$2}")
	if [ "${__current}" = "${__value}" ]; then
		echo_date "'${__key}' is already set"
	else
		echo_date "Setting ${__key}..."
		sudo pmset -a "${__key}" "${__value}"
	fi
}
if [ -n "${IS_MAC_MINI_DW}" ]; then
	set_pm_value sleep 0
	set_pm_value disksleep 10
	set_pm_value displaysleep 10
fi

# machine - system configuration
set_scutil_names() {
	set_scutil_value ComputerName "$1"
	set_scutil_value HostName "$1"
	set_scutil_value LocalHostName "$1"

}
set_scutil_value() {
	__key="$1"
	__value="$2"
	__current=$(scutil --get "${__key}" 2>/dev/null || echo "")
	if [ "${__current}" = "${__value}" ]; then
		echo_date "'${__key}' is already set"
	else
		echo_date "Setting ${__key}..."
		sudo scutil --set "${__key}" "${__value}"
	fi
}

if [ -n "${IS_MAC_MINI_DW}" ]; then
	set_scutil_names 'DW-Mac'
elif [ -n "${IS_MAC_MINI_RH}" ]; then
	set_scutil_names 'RH-Mac'
elif [ -n "${IS_MACBOOK}" ]; then
	set_scutil_names 'RH-MacBook'
fi

# machine - SSH
add_private_key() {
	__path="${HOME}/.ssh/id_ed25519"
	if [ -f "${__path}" ]; then
		ssh-add --apple-use-keychain "${__path}"
	else
		echo_date "ERROR: SSH private key not found"
	fi
}
enable_sshd() {
	if launchctl print system/com.openssh.sshd >/dev/null 2>&1; then
		echo_date "'sshd' is already set"
	else
		echo_date "Enabling 'sshd'..."
		sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
	fi
}
[ -n "${IS_MAC}" ] && add_private_key
[ -n "${IS_MAC}" ] && enable_sshd

# brew
if command -v brew >/dev/null 2>&1; then
	echo_date "'brew' is already installed"
else
	echo_date "Installing 'brew'..."
	if [ -n "${IS_UBUNTU}" ]; then
		sudo apt-get update
		sudo apt-get install -y build-essential procps curl file git
	fi
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# brew/install
[ -n "${IS_MAC}" ] && brew_install 1password --cask
brew_install aichat
brew_install asciinema
[ -n "${IS_MAC_MINI}" ] && brew_install autoconf # for c
[ -n "${IS_MAC_MINI}" ] && brew_install automake # for c
[ -n "${IS_MAC_MINI}" ] && brew_install bacon
[ -n "${IS_MAC_MINI}" ] && brew_install cargo-binstall
[ -n "${IS_MAC_MINI}" ] && brew_install cargo-nextest
[ -n "${IS_MAC_MINI}" ] && brew_install db-browser-for-sqlite --cask
[ -n "${IS_MAC_MINI}" ] && brew_install libreoffice --cask
# brew_install node > brew link --overwrite node
[ -n "${IS_MAC_MINI}" ] && brew_install pgadmin4 --cask
[ -n "${IS_MAC_MINI}" ] && brew_install pgcli
[ -n "${IS_MAC_MINI}" ] && brew_install postgres postgresql@17
brew_install prettier
[ -n "${IS_MAC_MINI}" ] && brew_install redis-stack --cask
brew_install rename
brew_install rust-analyzer

# brew/services
brew_services() {
	__app="$1"
	if ! command -v brew >/dev/null 2>&1; then
		echo_date "ERROR: 'brew' is not installed"
		return 1
	elif brew services list | grep -q "^${__app}[[:space:]]\+started"; then
		echo_date "'${__app}' is already started"
		return 0
	else
		echo_date "Starting '${__app}'..."
		brew services start "${__app}"
	fi
}
[ -n "${IS_MAC_MINI}" ] && brew_services postgresql@17
[ -n "${IS_MAC_MINI}" ] && brew_services redis
[ -n "${IS_MAC_MINI_DW}" ] && brew_services syncthing
[ -n "${IS_MAC_MINI}" ] && brew_services tailscale

# mac mini/rust
if [ -n "${IS_MAC_MINI}" ]; then
	if [ -d "${HOME}"/.cargo ]; then
		echo_date "'rust' is already installed"
	else
		echo_date "Installing 'rust'..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		rustup default stable
	fi
fi

# ubuntu/apt
apt_install() {
	__app="$1"
	__iname="${2:-$1}"
	if command -v "${__app}" >/dev/null 2>&1; then
		echo_date "'${__app}' is already installed"
		return 0
	else
		echo_date "Installing '${__app}'..."
		sudo apt-get update
		sudo apt-get install -y "${__iname}"
	fi
}
if [ -n "${IS_UBUNTU}" ]; then
	apt_install libgtk-3-0 # for keymapp
	apt_install libpq-dev
	apt_install libusb-1.0-0  # for keymapp
	apt_install libwebkit2gtk # for keymapp
	apt_install openssh-server
fi

# ubuntu/keymapp
if [ -n "${IS_UBUNTU}" ]; then
	if getent group plugdev >/dev/null 2>&1; then
		echo_date "'plugdev' already exists"
	else
		echo_date "Creating 'plugdev'..."
		sudo groupadd plugdev
	fi
	if id -nG "${USER}" | grep -qw plugdev; then
		echo "'${USER}' is already in 'plugdev'"
	else
		echo "Adding ${USER} to 'plugdev'..."
		sudo usermod -aG plugdev "$USER"
	fi
fi

# ubuntu/systemctl
set_systemctl() {
	__app="$1"
	if systemctl is-enabled "${__app}"; then
		echo_date "'${__app}' is already enabled..."
	else
		echo_date "Enabling '${__app}'..."
		sudo systemctl enable --now "${__app}"
	fi
}
[ -n "${IS_UBUNTU}" ] && set_systemctl redis-server
[ -n "${IS_UBUNTU}" ] && set_systemctl ssh

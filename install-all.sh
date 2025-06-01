#!/usr/bin/env sh

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# detect OS/Mac model
OS_NAME="$(uname)"
case "$OS_NAME" in
Darwin)
	MAC_MODEL=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')
	case "${MAC_MODEL}" in
	Mac14,12)
		echo_date "Detected Mac-Mini..."
		IS_MAC_MINI=1
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
if [ -n "${IS_MAC_MINI}" ] || [ -n "${IS_MACBOOK}" ]; then
	IS_MAC=1
fi

# machine-specific
if [ -n "${IS_MAC_MINI}" ]; then
	# power management
	set_pm_value() {
		key=$1
		value=$2
		current=$(pmset -g custom | awk "/[[:space:]]${key}[[:space:]]/ {print \$2}")
		if [ "${current}" = "${value}" ]; then
			echo_date "'${key}' is already set"
		else
			echo_date "Setting ${key}..."
			sudo pmset -a "${key}" "${value}"
		fi
	}
	set_pm_value sleep 0
	set_pm_value disksleep 10
	set_pm_value displaysleep 10

	# system configuration
	set_scutil_value() {
		key=$1
		value=$2
		current=$(scutil --get "${key}" 2>/dev/null || echo "")
		if [ "${current}" = "${value}" ]; then
			echo_date "'${key}' is already set"
		else
			echo_date "Setting ${key}..."
			sudo scutil --set "${key}" "${value}"
		fi
	}
	set_scutil_value ComputerName 'DW-Mac'
	set_scutil_value HostName 'DW-Mac'
	set_scutil_value LocalHostName 'DW-Mac'
fi

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

brew_install() {
	app_name="$1"
	install_name="${2:-$app_name}"
	if command -v "${app_name}" >/dev/null 2>&1; then
		echo_date "'${app_name}' is already installed"
	else
		if command -v brew >/dev/null 2>&1; then
			echo_date "Installing '${app_name}'..."
			brew install "${install_name}"
		else
			echo_date "ERROR: 'brew' is not installed"
		fi
	fi
}

brew_install bat
brew_install btm bottom
brew_install bump-my-version
brew_install delta git-delta
brew_install direnv
brew_install dust
brew_install eza
brew_install fd
brew_install fzf
brew_install gh
[ -n "${IS_MAC_MINI}" ] && brew_install gitweb yoannfleurydev/gitweb/gitweb
[ -n "${IS_MAC}" ] && brew_install gsed gnu-sed
brew_install just
[ -n "${IS_MAC_MINI}" ] || [ -n "${IS_UBUNTU}" ] && brew_install luacheck

# [ -n "${IS_MAC_MINI}" ] || [ -n "${IS_UBUNTU}" ] && brew install 1

# rust
if [ -n "${IS_MAC_MINI}" ]; then
	if [ -d "${HOME}"/.cargo ]; then
		echo_date "'rust' is already installed"
	else
		echo_date "Installing 'rust'..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	fi
fi

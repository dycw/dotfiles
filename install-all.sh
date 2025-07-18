#!/usr/bin/env sh

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

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
if [ -n "${IS_MAC_MINI}" ] || [ -n "${IS_MAC_MINI}" ]; then
	IS_MAC=1
fi
if [ -n "${IS_MAC_MINI}" ] || [ -n "${IS_MACBOOK}" ]; then
	IS_MAC=1
fi

# machine - power management
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
	key="$1"
	value="$2"
	current=$(scutil --get "${key}" 2>/dev/null || echo "")
	if [ "${current}" = "${value}" ]; then
		echo_date "'${key}' is already set"
	else
		echo_date "Setting ${key}..."
		sudo scutil --set "${key}" "${value}"
	fi
}

if [ -n "${IS_MAC_MINI_DW}" ]; then
	set_scutil_names 'DW-Mac'
elif [ -n "${IS_MAC_MINI_RH}" ]; then
	set_scutil_names 'RH-Mac'
elif [ -n "${IS_MACBOOK}" ]; then
	set_scutil_names 'RH-MacBook'
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

# brew/install
brew_install() {
	unset __app __cask __iname __tap
	while [ "$1" ]; do
		case "$1" in
		--cask)
			__cask=1
			shift
			;;
		--tap)
			__tap="$2"
			shift 2
			;;
		*)
			if [ -z "${__app}" ]; then
				__app="$1"
			elif [ -z "${__iname}" ]; then
				__iname="$1"
			fi
			shift
			;;
		esac
	done
	if [ -z "${__app}" ]; then
		echo_date "ERROR: 'app' not defined"
		return 1
	elif [ -z "${__iname}" ]; then
		__iname="${__app}"
	fi
	if ! command -v brew >/dev/null 2>&1; then
		echo_date "ERROR: 'brew' is not installed"
		return 1
	elif { [ -n "${__cask}" ] && brew list --cask "${__app}" >/dev/null 2>&1; } ||
		{ [ -n "${__cask}" ] && find /Applications -maxdepth 1 -type d -iname "*${__app}*.app" | grep -q .; } ||
		{ [ -z "${__cask}" ] && command -v "${__app}" >/dev/null 2>&1; }; then
		echo_date "'${__app}' is already installed"
		return 0
	else
		echo_date "Installing '${__app}'..."
		[ -n "${__tap}" ] && brew tap "${__tap}"
		if [ -n "${__cask}" ]; then
			brew install --cask "${__app}"
		else
			echo "${__iname}"
			brew install "${__iname}"
		fi
	fi

}

[ -n "${IS_MAC}" ] && brew_install 1password --cask
[ -n "${IS_MAC_MINI}" ] && brew_install autoconf # for c
[ -n "${IS_MAC_MINI}" ] && brew_install automake # for c
brew_install bat
brew_install btm bottom
brew_install bump-my-version
[ -n "${IS_MAC_MINI_DW}" ] && brew_install db-browser-for-sqlite --cask
brew_install delta git-delta
brew_install direnv
[ -n "${IS_MAC}" ] && brew_install dropbox --cask
brew_install dust
brew_install eza
brew_install fd
brew_install fzf
brew_install gh
[ -n "${IS_MAC}" ] && brew_install gitweb yoannfleurydev/gitweb/gitweb
[ -n "${IS_MAC}" ] && brew_install gsed gnu-sed
brew_install jq
brew_install just
[ -n "${IS_MAC_MINI}" ] && brew_install libreoffice --cask
brew_install luacheck
brew_install nvim neovim
brew_install pgadmin4 --cask
brew_install pgcli
[ -n "${IS_MAC}" ] && brew_install postgres postgresql@17
[ -n "${IS_MAC_MINI}" ] && brew_install postico --cask
brew_install pre-commit
brew_install prettier
[ -n "${IS_MAC}" ] && brew_install protonvpn --cask
[ -n "${IS_MAC_MINI}" ] && brew_install redis-stack-server redis-stack --tap=redis-stack/redist
[ -n "${IS_MAC_MINI_DW}" ] && brew_install restic
brew_install rg ripgrep
[ -n "${IS_MAC}" ] && brew_install rlwrap
brew_install ruff
brew_install shellcheck
brew_install shfmt
[ -n "${IS_MAC_MINI}" ] && brew_install spotify --cask
brew_install sshpass
brew_install starship
brew_install stylua
brew_install tailscale
brew_install tmux
brew_install topgrade
[ -n "${IS_MAC_MINI_DW}" ] && brew_install transmission --cask
brew_install uv
[ -n "${IS_MAC_MINI_DW}" ] && brew_install visual-studio-code --cask
[ -n "${IS_MAC_MINI_DW}" ] && brew_install vlc --cask
[ -n "${IS_MAC}" ] && brew_install watch
brew_install watchexec
[ -n "${IS_MAC}" ] && brew_install wezterm --cask
[ -n "${IS_MAC_MINI}" ] && brew_install whatsapp --cask
[ -n "${IS_UBUNTU}" ] && brew_install xclip
[ -n "${IS_UBUNTU}" ] && brew_install xsel
[ -n "${IS_MAC}" ] && brew_install yq
[ -n "${IS_MAC_MINI}" ] && brew_install zoom --cask
echo installing zoom
brew_install zoom --cask
brew_install zoxide
# brew/fzf
fzf_zsh="${XDG_CONFIG_HOME:-${HOME}/.config}/fzf/fzf.zsh"
if [ -f "$fzf_zsh" ]; then
	echo_date "'fzf' is already setup"
else
	echo_date "Setting up 'fzf'..."
	if ! command -v brew >/dev/null 2>&1; then
		"$(brew --prefix)/opt/fzf/install" --xdg --key-bindings --completion --no-update-rc --no-fish
	else
		echo_date "ERROR: 'brew' is not installed"
		return 1
	fi
fi

# brew/services
brew_services() {
	unset __brew_services_app
	__brew_services_app="$1"

	if ! command -v brew >/dev/null 2>&1; then
		echo_date "ERROR: 'brew' is not installed"
		return 1
	elif brew services list | grep -q "^${__brew_services_app}[[:space:]]\+started"; then
		echo_date "'${__brew_services_app}' is already started"
		return 0
	else
		echo_date "Starting '${__brew_services_app}'..."
		brew services start "${__brew_services_app}"
	fi
}
[ -n "${IS_MAC_MINI_DW}" ] && brew_services postgresql@17
[ -n "${IS_MAC_MINI_DW}" ] && brew_services redis

# mac mini/rust
if [ -n "${IS_MAC_MINI_DW}" ]; then
	if [ -d "${HOME}"/.cargo ]; then
		echo_date "'rust' is already installed"
	else
		echo_date "Installing 'rust'..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	fi
fi

# ubuntu/apt
apt_install() {
	unset __apt_install_app __apt_install_iname
	__apt_install_app="$1"
	__apt_install_iname="${2:-$1}"

	if command -v "${__apt_install_app}" >/dev/null 2>&1; then
		echo_date "'${__apt_install_app}' is already installed"
		return 0
	else
		echo_date "Installing '${__apt_install_app}'..."
		sudo apt-get update
		sudo apt-get install -y "${__apt_install_iname}"
	fi
}
if [ -n "${IS_UBUNTU}" ]; then
	apt_install curl
	apt_install libpq-dev
	apt_install nautilus-dropbox
	apt_install git
	apt_install zsh
fi

# ubuntu/shell
if [ -n "${IS_UBUNTU}" ]; then
	if [ "$(basename "${SHELL}")" = 'zsh' ]; then
		echo_date "'zsh' is already the default shell"
	else
		zsh_path="$(command -v zsh 2>/dev/null)"
		if [ -x "${zsh_path}" ]; then
			echo_date "Changing default shell to 'zsh'..."
			sudo chsh -s "${zsh_path}" "$(whoami)"
		else
			echo_date "ERROR: 'zsh' not found or not executable"
			return 1
		fi
	fi
fi

# ubuntu/snap
snap_install() {
	unset __snap_install_app
	__snap_install_app="$1"

	if command -v "${__snap_install_app}" >/dev/null 2>&1; then
		echo_date "'${__snap_install_app}' is already installed"
		return 0
	else
		echo_date "Installing '${__snap_install_app}'..."
		sudo snap install -y "${__snap_install_app}"
	fi
}
if [ -n "${IS_UBUNTU}" ]; then
	snap_install pdfarranger
	snap_install whatsapp-linux-app
fi

# ubuntu/wezterm
if [ -n "${IS_UBUNTU}" ]; then
	if command -v wezterm >/dev/null 2>&1; then
		echo_date "'wezterm' is already installed"
	else
		echo_date "Installing 'wezterm'..."
		curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
		echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
		sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
		sudo apt update
		sudo apt install wezterm
	fi
fi

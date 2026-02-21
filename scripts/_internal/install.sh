#!/usr/bin/env sh
# shellcheck disable=SC1091,SC2016

set -eu

#### start ####################################################################

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing apps on '$(hostname)'..."

#### determine system #########################################################

unset system
if [ "$(uname)" = Linux ] && [ -r /etc/os-release ]; then
	. /etc/os-release
	if [ "${ID:-}" = debian ]; then
		system=debian
	fi
elif [ "$(uname)" = Darwin ]; then
	model=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')
	case "${model}" in
	Mac14,12 | Mac14,3) system=macmini ;;
	MacBook*) system=macbook ;;
	*) ;;
	esac
fi

#### configs ##################################################################

script_dir=$(dirname -- "$(realpath -- "$0")")
configs="$(dirname -- "$(dirname -- "${script_dir}")")"/configs

#### per-system ###############################################################

case "${system:-}" in
debian)
	sh "${configs}"/sudo/install.sh "${system}"
	if [ "$(id -u)" -eq 0 ]; then
		apt-get update
		apt-get dist-upgrade -y
		apt-get autoremove -y
		apt-get clean
	else
		sudo apt-get update
		sudo apt-get dist-upgrade -y
		sudo apt-get autoremove -y
		sudo apt-get clean
	fi
	sh "${configs}"/curl/install.sh "${system}"
	;;
macmini)
	sh "${configs}"/homebrew/install.sh "${system}"
	;;
macbook) ;;
*)
	echo "Unsupported system '${system}'; exiting..." >&2
	exit 1
	;;
esac
sh "${configs}"/uv/install.sh ${system}

#### sub-installers ###########################################################

find "${configs}" -type f -name 'install.sh' ! -path "${configs}/tmux/.tmux/*" | sort | while IFS= read -r script; do
	sh "${script}" "${system}"
done

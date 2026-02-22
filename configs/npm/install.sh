#!/usr/bin/env sh

set -eu

###############################################################################

if command -v npm >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'npm' is already installed"
	exit
fi

case "$1" in
debian)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'npm'..."
	if [ "$(id -u)" -eq 0 ]; then
		apt-get install -y npm
	else
		sudo apt-get install -y npm
	fi
	;;
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'npm'..."
	brew install npm
	;;
macbook)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'npm'..."

	script_dir=$(dirname -- "$(realpath -- "$0")")
	configs=$(dirname -- "${script_dir}")

	link() {
		dest="${XDG_CONFIG_HOME:-${HOME}/.config}/$2"
		mkdir -p "$(dirname -- "${dest}")"
		ln -sfn "$1" "${dest}"
	}

	link_submodule_dir() {
		dir="$1"
		for file in "${configs}"/nvm/nvm.fish/"${dir}"/*.fish; do
			if [ -e "${file}" ]; then
				name=$(basename -- "${file}")
				link "${file}" "fish/${dir}/${name}"
			fi
		done
	}

	for dir in completions conf.d functions; do
		link_submodule_dir "${dir}"
	done

	nvm install latest
	;;
*) ;;
esac

#!/usr/bin/env sh

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# bottom
if command -v btm >/dev/null 2>&1; then
	echo_date "'bottom' is already installed"
else
	echo_date "Installing 'bottom'..."
	curl -LO https://github.com/ClementTsang/bottom/releases/download/0.11.1/bottom_0.11.1-1_amd64.deb &&
		sudo dpkg -i bottom_*_amd64.deb &&
		rm bottom_*_amd64.deb &&
		echo_date "Finished installing 'bottom'"
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
	echo_date "'direnv' is already installed"
else
	echo_date "Installing 'direnv'..."
	curl -sfL https://direnv.net/install.sh | bash &&
		printf "\n# direnv\nexport PATH=\"\$PATH:\$HOME/bin\"" >>"${HOME}/.bashrc" &&
		echo_date "Finished installing 'direnv'"
fi

# direnv
if command -v just >/dev/null 2>&1; then
	echo_date "'just' is already installed"
else
	(curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "${HOME}/bin") &&
		printf "\n# just\neval \"\$(direnv hook bash)\"" >>"${HOME}/.bashrc" &&
		echo_date "Finished installing 'just'"
fi

# neovim
if command -v just >/dev/null 2>&1; then
	echo_date "'just' is already installed"
else
	sudo apt install -y neovim &&
		printf '\n# neovim\nalias n="nvim"' >>"${HOME}/.bashrc" &&
		echo_date "Finished installing 'neovim'"
fi

# starship
if command -v starship >/dev/null 2>&1; then
	echo_date "'starship' is already installed"
else
	curl -sS https://starship.rs/install.sh | sh &&
		printf "\n# starship\neval \"\$(starship init bash)\"" >>"${HOME}/.bashrc" &&
		echo_date "Finished installing 'neovim'"
fi

#!/usr/bin/env sh

_install_citrix() {
	echo https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html

	path=/opt/Citrix/ICAClient/keystore/cacerts/
	sudo ln -s /usr/share/ca-certificates/mozilla/* $path
	sudo c_rehash $path
}

_install_citrix

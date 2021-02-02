#!/usr/bin/env bash

if ! dpkg -s nordvpn >/dev/null 2>&1; then
	printf "nordvpn not installed; installing...\n"
	filename="nordvpn-release_1.0.0_all.deb"
	wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/$filename -P /tmp
	sudo apt-get install --yes /tmp/$filename
	printf "nordvpn installed\n"
fi

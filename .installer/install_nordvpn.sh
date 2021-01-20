#!/usr/bin/env bash

if ! apt-get-has nordvpn; then
	timed_log "nordvpn not installed; installing...\n"
	filename="nordvpn-release_1.0.0_all.deb"
	wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/$filename -P /tmp
	sudo apt-get install --yes /tmp/$filename
	timed_log "nordvpn installed\n"
fi

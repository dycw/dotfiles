#!/usr/bin/env bash

if ! command -v nordvpn >/dev/null 2>&1; then
	name=nordvpn-release_1.0.0_all.deb
	tmp_dir="$(mktemp -d -t nordvpn-XXXXXX)"
	wget "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/$name" -P "$tmp_dir"
	sudo apt-get --yes install "$tmp_dir/$name"
fi

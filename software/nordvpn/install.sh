#!/usr/bin/env bash

if ! command -v nordvpn >/dev/null 2>&1; then
	VERSION=1.0.0
	tmp_dir="$(mktemp -d)"
	cd "$tmp_dir" || exit
	wget --output-file=package.deb "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_${VERSION}_all.deb"
	sudo apt-get --yes install package.deb
fi

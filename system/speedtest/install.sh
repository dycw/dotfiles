#!/usr/bin/env bash

name=speedtest
if ! command -v "$name" >/dev/null 2>&1; then
	sudo apt-get --yes install apt-transport-https dirmngr gnupg1
	export INSTALL_KEY=379CE192D401AB61
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$INSTALL_KEY"
	echo "deb https://ookla.bintray.com/debian generic main" | sudo tee /etc/apt/sources.list.d/speedtest.list
	sudo apt-get update
	sudo apt-get --yes install "$name"
fi

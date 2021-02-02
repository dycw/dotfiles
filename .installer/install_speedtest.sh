#!/usr/bin/env bash

if ! dpkg -s speedtest >/dev/null 2>&1; then
	printf "speedtest not installed; installing...\n"
	declare -a programs=()
	programs+=("apt-transport-https")
	programs+=("dirmngr")
	programs+=("gnupg1")
	for program in "${programs[@]}"; do
		if ! dpkg -s "$program" >/dev/null 2>&1; then
			printf "%s not installed; installing...\n" "$program"
			sudo apt-get --yes install "$program"
			printf "%s installed\n" "$program"
		fi
	done
	export INSTALL_KEY=379CE192D401AB61
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY
	echo "deb https://ookla.bintray.com/debian generic main" | sudo tee /etc/apt/sources.list.d/speedtest.list
	sudo apt-get update
	sudo apt-get --yes install speedtest
	printf "speedtest installed\n"
fi

#!/usr/bin/env bash

if ! apt-get-has speedtest; then
	timed_log "speedtest not installed; installing...\n"
	declare -a programs=()
	programs+=("apt-transport-https")
	programs+=("dirmngr")
	programs+=("gnupg1")
	for program in "${programs[@]}"; do
		if ! apt-get-has "$program"; then
			timed_log "%s not installed; installing...\n" "$program"
			sudo apt-get --yes install "$program"
			timed_log "%s installed\n" "$program"
		fi
	done
	export INSTALL_KEY=379CE192D401AB61
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY
	echo "deb https://ookla.bintray.com/debian generic main" | sudo tee /etc/apt/sources.list.d/speedtest.list
	sudo apt-get update
	sudo apt-get --yes install speedtest
	timed_log "speedtest installed\n"
fi

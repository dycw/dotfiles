#!/usr/bin/env bash

declare -a programs=()
programs+=("gnome-tweaks")
programs+=("chrome-gnome-shell")
for program in "${programs[@]}"; do
	if ! dpkg -s "$program" >/dev/null 2>&1; then
		printf "%s not installed; installing...\n" "$program"
		sudo apt-get --yes install "$program"
		printf "%s installed\n" "$program"
	fi
done

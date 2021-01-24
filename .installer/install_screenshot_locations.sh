#!/usr/bin/env bash

declare -a programs=()
programs+=("gnome-tweaks")
programs+=("chrome-gnome-shell")
for program in "${programs[@]}"; do
	if ! dpkg -s "$program" >/dev/null 2>&1; then
		timed_log "%s not installed; installing...\n" "$program"
		sudo apt-get --yes install "$program"
		timed_log "%s installed\n" "$program"
	fi
done

#!/usr/bin/env bash

declare -a programs=()
programs+=("gnome-tweaks")
programs+=("chrome-gnome-shell")
for program in "${programs[@]}"; do
	if ! command -v "${program}" >/dev/null 2>&1; then
		sudo apt-get --yes install "${program}"
	fi
done

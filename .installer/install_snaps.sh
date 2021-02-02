#!/usr/bin/env bash

declare -a programs=()
programs+=("code")
programs+=("insomnia-designer")
programs+=("spotify")
programs+=("sqlitebrowser")
programs+=("vlc")
for program in "${programs[@]}"; do
	if ! snap list | grep -q "$program"; then
		printf "%s not installed; installing...\n" "$program"
		sudo snap install "$program"
		printf "%s installed\n" "$program"
	fi
done

declare -a programs=()
programs+=("ripgrep")
for program in "${programs[@]}"; do
	if ! snap list | grep -q "$program"; then
		printf "%s not installed; installing...\n" "$program"
		sudo snap install --classic "$program"
		printf "%s installed\n" "$program"
	fi
done

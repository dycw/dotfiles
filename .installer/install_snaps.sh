#!/usr/bin/env bash

declare -a programs=()
programs+=("code")
programs+=("insomnia-designer")
programs+=("spotify")
programs+=("sqlitebrowser")
programs+=("vlc")
for program in "${programs[@]}"; do
	if ! snap list | grep -q "$program"; then
		timed_log "%s not installed; installing...\n" "$program"
		sudo snap install "$program"
		timed_log "%s installed\n" "$program"
	fi
done

declare -a programs=()
programs+=("loop-rs")
for program in "${programs[@]}"; do
	if ! snap list | grep -q "$program"; then
		timed_log "%s not installed; installing...\n" "$program"
		sudo snap install --beta "$program"
		timed_log "%s installed\n" "$program"
	fi
done

declare -a programs=()
programs+=("pre-commit")
for program in "${programs[@]}"; do
	if ! snap list | grep -q "$program"; then
		timed_log "%s not installed; installing...\n" "$program"
		sudo snap install --classic "$program"
		timed_log "%s installed\n" "$program"
	fi
done

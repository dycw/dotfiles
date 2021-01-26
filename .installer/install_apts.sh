#!/usr/bin/env bash

declare -a programs=()
programs+=("bat")
programs+=("calibre")
programs+=("curl")
programs+=("direnv")
programs+=("fd-find")
programs+=("fzf")
programs+=("glances")
programs+=("gparted")
programs+=("htop")
programs+=("i3")
programs+=("progress")
programs+=("restic")
programs+=("shellcheck")
programs+=("tmux")
programs+=("transmission")
programs+=("vim")
for program in "${programs[@]}"; do
	if ! dpkg -s "$program" >/dev/null 2>&1; then
		timed_log "%s not installed; installing...\n" "$program"
		sudo apt-get --yes install "$program"
		timed_log "%s installed\n" "$program"
	fi
done

# _ensure_apt g++      # ?
# _ensure_apt gcc      # ?
# _ensure_apt gfortran # scipy

# _ensure_apt libatlas-base-dev # scipy
# _ensure_apt libblas-dev       # scipy
# _ensure_apt libblas3          # scipy
# _ensure_apt liblapack-dev     # scipy
# _ensure_apt liblapack3        # scipy

#!/usr/bin/env bash

# https://itectec.com/ubuntu/ubuntu-ubuntu-20-04-bluetooth-not-working/

if ! dpkg -s blueman >/dev/null 2>&1; then
	timed_log "blueman not installed; installing...\n"
	sudo apt install blueman
	timed_log "blueman installed\n"
fi

if ! dpkg -s rtbth-dkms >/dev/null 2>&1; then
	timed_log "rtbth-dkms not installed; installing...\n"
	sudo add-apt-repository ppa:blaze/rtbth-dkms
	sudo apt-get update
	sudo apt-get install rtbth-dkms
	timed_log "rtbth-dkms installed\n"
fi

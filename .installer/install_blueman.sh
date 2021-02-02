#!/usr/bin/env bash

# https://itectec.com/ubuntu/ubuntu-ubuntu-20-04-bluetooth-not-working/

if ! dpkg -s blueman >/dev/null 2>&1; then
	printf "blueman not installed; installing...\n"
	sudo apt install blueman
	printf "blueman installed\n"
fi

if ! dpkg -s rtbth-dkms >/dev/null 2>&1; then
	printf "rtbth-dkms not installed; installing...\n"
	sudo add-apt-repository ppa:blaze/rtbth-dkms
	sudo apt-get update
	sudo apt-get install rtbth-dkms
	printf "rtbth-dkms installed\n"
fi

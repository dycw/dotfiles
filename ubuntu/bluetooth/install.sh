#!/usr/bin/env bash

# https://itectec.com/ubuntu/ubuntu-ubuntu-20-04-bluetooth-not-working/

if ! dpkg -s blueman >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install blueman
fi

if ! dpkg -s rtbth-dkms >/dev/null 2>&1; then
	sudo add-apt-repository ppa:blaze/rtbth-dkms
	sudo apt-get update
	sudo apt-get --yes install rtbth-dkms
fi

#!/usr/bin/env bash

if [ "$USER" == "Install IB please" ]; then
	name=ibgateway-stable-standalone-linux-x64.sh
	tmp_dir="$(mktemp -d -t ibgateway-XXXXXX)"
	wget "https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/$name" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	chmod u+x "$name"
	"./$name"
fi

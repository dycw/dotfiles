#!/usr/bin/env bash

if [ "$USER" == "Install IB please" ]; then
	tmp_dir="$(mktemp -d)"
	cd "$tmp_dir" || exit
	wget --output-file=script.sh https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
	chmod u+x script.sh
	# shellcheck source=/dev/null
	source script.sh
fi

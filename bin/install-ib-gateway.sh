#!/usr/bin/env sh

_install_ib_gateway() {
	filename=ibgateway-stable-standalone-linux-x64.sh
	wget https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/$filename -P /tmp
	full_filename=/tmp/$filename
	chmod u+x $full_filename
	$full_filename
}

_install_ib_gateway

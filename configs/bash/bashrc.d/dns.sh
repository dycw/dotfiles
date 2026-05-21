# shellcheck shell=bash
if [ "$(uname)" = Darwin ]; then
	flush() {
		sudo dscacheutil -flushcache
		sudo killall -HUP mDNSResponder
	}
fi

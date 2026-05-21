# shellcheck shell=bash
if [ "$(uname)" = Linux ]; then
	resolv-conf() {
		if [ "$(id -u)" -eq 0 ]; then
			chattr -i /etc/resolv.conf || true
			"${EDITOR}" /etc/resolv.conf
			chattr +i /etc/resolv.conf || true
		else
			sudo chattr -i /etc/resolv.conf || true
			sudo "${EDITOR}" /etc/resolv.conf
			sudo chattr +i /etc/resolv.conf || true
		fi
	}
	watch-resolv-conf() {
		watch --color --differences --interval=1 -- cat /etc/resolv.conf
	}
fi

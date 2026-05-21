# shellcheck shell=bash
l() {
	if command -v eza >/dev/null 2>&1; then
		la --git-ignore "$@"
	else
		la "$@"
	fi
}

la() {
	if command -v eza >/dev/null 2>&1; then
		eza --all --classify=always --git --group --group-directories-first \
			--header --long --time-style=long-iso "$@"
	else
		ls -ahl --color=always "$@"
	fi
}

if command -v eza >/dev/null 2>&1; then
	wl() {
		watch --color --differences --interval=1 -- \
			eza --all --classify=always --color=always --git --group \
			--group-directories-first --header --long --reverse \
			--sort=modified --time-style=long-iso "$@"
	}
fi

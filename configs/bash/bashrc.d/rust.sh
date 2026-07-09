# shellcheck shell=sh
if command -v rustup >/dev/null 2>&1; then
	_rustup_completion=$(rustup completions bash 2>/dev/null) && eval "${_rustup_completion}"
	if rustup show active-toolchain >/dev/null 2>&1; then
		_cargo_completion=$(rustup completions bash cargo 2>/dev/null) && eval "${_cargo_completion}"
	fi
	unset _rustup_completion _cargo_completion
fi

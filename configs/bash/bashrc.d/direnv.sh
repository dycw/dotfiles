# shellcheck shell=sh
if command -v direnv >/dev/null 2>&1; then
	eval "$(direnv hook bash)"
	dea() { direnv allow .; }
fi

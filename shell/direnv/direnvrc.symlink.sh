#!/usr/bin/env bash
# symlink~/.config/direnv/direnvrc

layout_anaconda() {
	local ACTIVATE="${HOME}/miniconda3/bin/activate"

	if [ -n "$1" ]; then
		# Explicit environment name from layout command.
		local env_name="$1"
		# shellcheck source=/dev/null
		source "$ACTIVATE" "${env_name}"
	elif (grep -q name: environment.yml); then
		# Detect environment name from `environment.yml` file in `.envrc` directory
		# shellcheck source=/dev/null
		source "$ACTIVATE" "$(grep name: environment.yml | sed -e 's/name: //' | cut -d "'" -f 2 | cut -d '"' -f 2)"
	else
		(echo >&2 No environment specified)
		exit 1
	fi
}

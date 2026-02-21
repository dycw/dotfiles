#!/usr/bin/env sh
# shellcheck disable=SC1090

set -eu

#### start ####################################################################

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up '$(hostname)'..."

#### sub-installers ###########################################################

script_dir=$(dirname -- "$(realpath -- "$0")")
configs="$(dirname -- "$(dirname -- "${script_dir}")")"/configs
find "${configs}" -type f -name set-up.sh | sort | while IFS= read -r script; do
	sh "${script}"
done

#!/usr/bin/env sh

set -eu

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up 'keymapp'..."

temp_dir="$(mktemp -d)"
trap 'rm -rf "${temp_dir}"' EXIT

url='https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz'
curl -fsSL "${url}" | tar -xz -C "${temp_dir}"

install -Dm755 "${temp_dir}/keymapp" "${HOME}/.local/bin/keymapp"

#!/usr/bin/env sh

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT

URL='https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz'
curl -fsSL "${URL}" | tar -xz -C "${TEMP_DIR}"

install -Dm755 "${TEMP_DIR}/keymapp" "${HOME}/.local/bin/keymapp"

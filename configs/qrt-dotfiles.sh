#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ]; then
	return
fi

for base in "${HOME}/work" "${HOME}/work/derek"; do
	dotfiles="${base}/qrt-dotfiles"
	if [ ! -d "${dotfiles}" ]; then
		continue
	fi
	yaml="${dotfiles}/tea/config.yml"
	if [ -f "${yaml}" ]; then
		mkdir -p "${HOME}/.config/tea"
		ln -sfn "${yaml}" "${HOME}/.config/tea/config.yml"
	fi
done

#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v prek >/dev/null 2>&1; then
	return
fi

__prek_auto_update() {
	prek auto-update --jobs=10 --verbose
}

__prek_run() {
	prek run --all-files --show-diff-on-failure --quiet
}

pg() {
	__prek_auto_update
	__prek_run
	if command -v __git_all >/dev/null 2>&1; then
		__git_all
	fi
}

pr() {
	__prek_run
}

prf() {
	rm -rf "${HOME}/.cache/pre-commit-hooks/throttle"
	__prek_run
}

pri() {
	prek install --overwrite --install-hooks
}

pru() {
	prek uninstall
}

pu() {
	__prek_auto_update
}

pur() {
	__prek_auto_update
	__prek_run
	if command -v __git_all >/dev/null 2>&1; then
		__git_all
	fi
}

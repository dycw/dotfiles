#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 0 ]]; then
	printf 'usage: %s\n' "$0" >&2
	exit 2
fi

if [[ "$(uname -s)" != Darwin ]]; then
	printf 'Safari Web Extensions can only be converted on macOS.\n' >&2
	exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
	printf 'Install Xcode or the Xcode command line tools first.\n' >&2
	exit 1
fi

if ! xcrun --find safari-web-extension-converter >/dev/null 2>&1; then
	printf 'safari-web-extension-converter is unavailable; install a full Xcode release.\n' >&2
	exit 1
fi

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
repo_root=$(CDPATH='' cd -- "${script_dir}/.." && pwd -P)
extension_source="${repo_root}/configs/safari/extension"
project_dir=${SAFARI_EXTENSION_PROJECT:-"${HOME}/Applications/Safari Tab Organizer"}

case "${project_dir}" in
/*) ;;
*)
	printf 'SAFARI_EXTENSION_PROJECT must be an absolute path.\n' >&2
	exit 2
	;;
esac

if [[ -e "${project_dir}" || -L "${project_dir}" ]]; then
	printf 'Refusing to overwrite existing project: %s\n' "${project_dir}" >&2
	exit 1
fi

build_root=$(mktemp -d /tmp/safari-tab-organizer.XXXXXX)
cleanup_build() {
	local build_status=$?
	rm -rf -- "${build_root}"
	exit "${build_status}"
}
trap cleanup_build EXIT
trap 'exit 1' HUP INT TERM
staged_project="${build_root}/Safari Tab Organizer"
converter_args=(
	"${extension_source}"
	--project-location "${staged_project}"
	--app-name "Safari Tab Organizer"
	--bundle-identifier com.dotfilesderek.safari-tab-organizer
)

if xcrun safari-web-extension-converter "${converter_args[@]}"; then
	:
else
	converter_status=$?
	printf 'Safari Web Extension conversion failed.\n' >&2
	exit "${converter_status}"
fi

if [[ ! -d "${staged_project}/Safari Tab Organizer.xcodeproj" ]]; then
	printf 'The converter did not create the expected Xcode project.\n' >&2
	exit 1
fi

mkdir -p -- "$(dirname -- "${project_dir}")"
if ! mv -- "${staged_project}" "${project_dir}"; then
	printf 'Could not install the generated project at %s\n' "${project_dir}" >&2
	exit 1
fi

printf 'Generated Safari Tab Organizer at %s\n' "${project_dir}"
printf 'Open the Xcode project, run the app, then enable the extension in Safari Settings.\n'

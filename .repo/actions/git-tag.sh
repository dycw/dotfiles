#!/bin/sh
# shellcheck disable=SC2154

set -eu

# shellcheck disable=SC1090,SC1091
. "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/common.sh"

tag_exists_local() {
	git -C "${repo_root}" rev-parse -q --verify "refs/tags/$1" >/dev/null 2>&1
}

tag_exists_remote() {
	git -C "${repo_root}" ls-remote --exit-code --tags origin "refs/tags/$1" >/dev/null 2>&1
}

[ -f "${version_file}" ] || fail "VERSION file not found; cannot tag push"
tag=$(read_trimmed_file "${version_file}")
[ -n "${tag}" ] || fail "VERSION file is empty"

sh "${repo_root}/.repo/actions/bump-version.sh" lint

if tag_exists_local "${tag}"; then
	log "tag ${tag} already exists locally; skipping"
	exit 0
fi

if tag_exists_remote "${tag}"; then
	log "tag ${tag} already exists on origin; skipping"
	exit 0
fi

git -C "${repo_root}" tag "${tag}"
git -C "${repo_root}" push origin "refs/tags/${tag}"
log "pushed tag ${tag}"

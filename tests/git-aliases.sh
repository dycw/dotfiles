#!/bin/sh

set -eu

repo_root=$(cd "$(dirname -- "$0")/.." && pwd)

bash --noprofile --norc "${repo_root}/configs/bash/bashrc.d/git.sh" -n

PATH_DOTFILES=${repo_root} bash --noprofile --norc <<'EOF'
set -euo pipefail
source "${PATH_DOTFILES}/configs/bash/bashrc.d/git.sh"

while IFS= read -r alias_name; do
	[ -n "${alias_name}" ] || continue
	type "g${alias_name}" >/dev/null
done < <(git config --file "${PATH_DOTFILES}/configs/git/config" --name-only --get-regexp '^alias\.' | sed 's/^alias\.//')

for name in gpl gp ga gl gbranch-default gfetch-default; do
	type "${name}" >/dev/null
done

work_dir=$(mktemp -d)
trap 'rm -rf -- "${work_dir}"' EXIT HUP INT TERM

clone_args="${work_dir}/git-args"
cd "${work_dir}"
git() {
	printf '%s\n' "$@" >"${clone_args}"
	mkdir -p -- "$4"
}
prek() { :; }
gcl ssh://git@gitea-server.ai:2222/qrt/monitoring.git
expected_clone_args='clone
--recurse-submodules
ssh://git@gitea-server.ai:2222/qrt/monitoring.git
monitoring'
test "$(cat "${clone_args}")" = "${expected_clone_args}"
test "${PWD}" = "${work_dir}"

(
	clean_checks=0
	git() {
		case "$1" in
		is-clean)
			clean_checks=$((clean_checks + 1))
			[ "${clean_checks}" -gt 1 ]
			;;
		current-branch) printf 'topic\n' ;;
		add | commit | push) return 0 ;;
		esac
	}
	__git_commit_until_push
)

create_args="${work_dir}/create-args"
(
	git() {
		case "$1" in
		remote-name) printf 'gitea\n' ;;
		default-remote-branch) printf 'origin/master\n' ;;
		current-branch) printf 'topic\n' ;;
		fetch-default | checkout | commit | push) return 0 ;;
		esac
	}
	tea() { printf '%s\n' "$@" >"${create_args}"; }
	__git_checkout_open --title Test --num derek/dotfiles#260 --part
)
expected_create_args='pulls
create
--title
Test
--description
Part of derek/dotfiles#260'
test "$(cat "${create_args}")" = "${expected_create_args}"

merge_args="${work_dir}/merge-args"
merge_state="${work_dir}/merge-state"
(
	git() {
		case "$1" in
		remote-name) printf 'gitea\n' ;;
		current-branch) printf 'topic\n' ;;
		repo-name) printf 'derek/dotfiles\n' ;;
		default-local-branch) printf 'master\n' ;;
		checkout | pull-default | branch-delete) return 0 ;;
		esac
	}
	tea() {
		if [ "$1" = pulls ] && [ "$2" = ls ]; then
			if [ ! -e "${merge_state}" ]; then
				: >"${merge_state}"
				printf 'topic\n'
			fi
		else
			printf '%s\n' "$@" >"${merge_args}"
		fi
	}
	__git_merge
)
expected_merge_args='pull
merge
--style
squash'
test "$(cat "${merge_args}")" = "${expected_merge_args}"
if compgen -A variable _git_ | grep -q .; then
	printf 'git alias loader leaked _git_* variables:\n' >&2
	compgen -A variable _git_ >&2
	exit 1
fi
EOF

python3 - "${repo_root}/configs/bash/bashrc.d/git.sh" <<'PY'
import re
import sys

allowed = {
    "EOF",
    "__git_create",
    "__git_merge",
    "break",
    "done",
    "else",
    "esac",
    "fi",
    "shift",
}

bad = []
with open(sys.argv[1], encoding="utf-8") as fh:
    for lineno, line in enumerate(fh, 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", stripped) and stripped not in allowed:
            bad.append(f"{lineno}: {stripped}")

if bad:
    print("unexpected standalone bare-word commands in git.sh:", file=sys.stderr)
    print("\n".join(bad), file=sys.stderr)
    sys.exit(1)
PY

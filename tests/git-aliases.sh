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

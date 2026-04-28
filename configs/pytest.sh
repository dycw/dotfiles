#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ]; then
	return
fi

export PY_COLORS=1

__pytest() {
	pytest --color=yes "$@"
}

_pytest_expr_required() {
	if [ "$#" -lt 1 ]; then
		echo "'$1' expected [1..) arguments EXPRESSION; got 0" >&2
		return 1
	fi
}

pyt() { __pytest "$@"; }
pytf() { __pytest --looponfail "$@"; }
pytfn() { __pytest --looponfail --numprocesses auto "$@"; }
pytfnr() { __pytest --force-regen --looponfail --numprocesses auto "$@"; }
pytfnx() { __pytest -x --looponfail --numprocesses auto "$@"; }
pytfr() { __pytest --force-regen --looponfail "$@"; }
pytfx() { __pytest --exitfirst --looponfail "$@"; }
pytn() { __pytest --numprocesses auto "$@"; }
pytnr() { __pytest --force-regen --numprocesses auto "$@"; }
pytnx() { __pytest --exitfirst --numprocesses auto "$@"; }
pytp() { __pytest --pdb "$@"; }
pytpx() { __pytest --exitfirst --pdb "$@"; }
pytr() { __pytest --force-regen "$@"; }
pytx() { __pytest --exitfirst "$@"; }

pytfk() {
	[ "$#" -ge 1 ] || {
		echo "'pytfk' expected [1..) arguments EXPRESSION; got $#" >&2
		return 1
	}
	expr=$1
	shift
	__pytest --looponfail -k "${expr}" "$@"
}

pytfxk() {
	[ "$#" -ge 1 ] || {
		echo "'pytfxk' expected [1..) arguments EXPRESSION; got $#" >&2
		return 1
	}
	expr=$1
	shift
	__pytest --exitfirst --looponfail -k "${expr}" "$@"
}

pytk() {
	[ "$#" -ge 1 ] || {
		echo "'pytk' expected [1..) arguments EXPRESSION; got $#" >&2
		return 1
	}
	expr=$1
	shift
	__pytest -k "${expr}" "$@"
}

pytnk() {
	[ "$#" -ge 1 ] || {
		echo "'pytnk' expected [1..) arguments EXPRESSION; got $#" >&2
		return 1
	}
	expr=$1
	shift
	__pytest --numprocesses auto -k "${expr}" "$@"
}

pytpk() {
	[ "$#" -ge 1 ] || {
		echo "'pytpk' expected [1..) arguments EXPRESSION; got $#" >&2
		return 1
	}
	expr=$1
	shift
	__pytest --pdb -k "${expr}" "$@"
}

pytpxk() {
	[ "$#" -ge 1 ] || {
		echo "'pytpxk' expected [1..) arguments EXPRESSION; got $#" >&2
		return 1
	}
	expr=$1
	shift
	__pytest --exitfirst --pdb -k "${expr}" "$@"
}

pytxk() {
	[ "$#" -ge 1 ] || {
		echo "'pytxk' expected [1..) arguments EXPRESSION; got $#" >&2
		return 1
	}
	expr=$1
	shift
	__pytest --exitfirst -k "${expr}" "$@"
}

from typing import Callable
from typing import cast
from typing import List
from typing import Optional
from typing import TypeVar

from pyt import _get_repo_root
from pyt import _parse_extra
from pyt import _yield_args
from pyt import Parsed
from pytest import mark
from pytest import param
from pytest import raises

T = TypeVar("T")


@cast(
    Callable[[T], T],
    mark.parametrize(
        "args, expected",
        [
            param([], Parsed(), id="none"),
            param(["p"], Parsed(pdb=True), id="p"),
            param(["pdb"], Parsed(pdb=True), id="pdb"),
            param(["-k", "test1"], Parsed(k=["test1"]), id="k, single"),
            param(
                ["-k", "test1", "-k", "test2"],
                Parsed(k=["test1", "test2"]),
                id="k, multiple",
            ),
            param(["-m", "mark1"], Parsed(m=["mark1"]), id="m, single"),
            param(
                ["-m", "mark1", "-m", "mark2"],
                Parsed(m=["mark1", "mark2"]),
                id="m, multiple",
            ),
            param(["-x"], Parsed(flags=["-x"]), id="flags, single-dash"),
            param(
                ["--maxfail=3"],
                Parsed(flags=["--maxfail=3"]),
                id="flags, double-dash",
            ),
            param(["1"], Parsed(n=1), id="n, int"),
            param(["-n1"], Parsed(n=1), id="n, dash"),
            param(["auto"], Parsed(n=0), id="n, auto"),
            param(["-nauto"], Parsed(n=0), id="n, dash auto"),
            param(["home"], Parsed(paths=["home"]), id="arg as path"),
            param(["main_test"], Parsed(k=["main_test"]), id="arg as -k, test name"),
            param(
                ["python/test_foo.py::test_foo"],
                Parsed(paths=["python/test_foo.py::test_foo"]),
                id="arg as -k, full test spec",
            ),
            param(
                ["python/test_foo.py::test_foo[case0]"],
                Parsed(paths=["python/test_foo.py::test_foo[case0]"]),
                id="arg as -k, full test case",
            ),
            param(
                ["home", "p"],
                Parsed(paths=["home"], pdb=True),
                id="arg as path, with --pdb",
            ),
        ],
    ),
)
def test_parse_extra(args: List[str], expected: List[str]) -> None:
    assert _parse_extra(*args) == expected  # noqa: S101


@cast(
    Callable[[T], T],
    mark.parametrize(
        "args, expected",
        [
            param([], ["--color=yes", "-f"], id="no --pdb, no -n"),
            param(["10"], ["--color=yes", "-f", "-n10"], id="no --pdb, yes -n"),
            param(["p"], ["--color=yes", "--pdb"], id="yes --pdb, no -n"),
            param(["p", "10"], None, id="yes --pdb, yes -n"),
        ],
    ),
)
def test_yield_args(args: List[str], expected: Optional[List[str]]) -> None:
    if expected is None:
        with raises(RuntimeError):
            list(_yield_args(*args))
    else:
        first, *rest = list(_yield_args(*args))
        assert first == "pytest"  # noqa: S101
        assert rest == expected  # noqa: S101


def test_get_repo_root() -> None:
    assert any(path.name == ".git" for path in _get_repo_root().iterdir())  # noqa: S101

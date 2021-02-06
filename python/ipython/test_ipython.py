from pathlib import Path
from runpy import run_path
from typing import Callable
from typing import cast
from typing import TypeVar

from pytest import mark


T = TypeVar("T")


STARTUP_FILES = [
    path
    for path in Path(__file__)
    .resolve()
    .parent.parent.joinpath("ipython", "startup")
    .iterdir()
    if path.is_file() and path.suffixes == [".py"]
]


def test_number_of_startup_files() -> None:
    assert len(STARTUP_FILES) == 12  # noqa: S101


@cast(Callable[[T], T], mark.parametrize("path", STARTUP_FILES, ids=lambda x: x.name))
def test_startup_files(path: Path) -> None:
    run_path(str(path))

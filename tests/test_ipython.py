from pathlib import Path
from runpy import run_path

from tests import parametrize


STARTUP_FILES = [
    path
    for path in Path(__file__)
    .resolve()
    .parent.parent.joinpath("ipython", "startup")
    .iterdir()
    if path.is_file() and path.suffixes == [".py"]
]


def test_number_of_startup_files() -> None:
    assert len(STARTUP_FILES) == 12


@parametrize("path", STARTUP_FILES, ids=lambda x: x.name)
def test_startup_files(path: Path) -> None:
    run_path(str(path))

from __future__ import annotations  # noqa: INP001

import abc
import sys
from abc import ABC, ABCMeta
from contextlib import suppress
from pathlib import Path
from subprocess import PIPE, CalledProcessError, check_output

from beartype import beartype  # type: ignore[]

_ = [
    abc,
    beartype,
    ABC,
    ABCMeta,
    suppress,
]


def _add_src_to_sys_path() -> None:
    try:
        output = check_output(
            ["git", "rev-parse", "--show-toplevel"],  # noqa: S603, S607
            stderr=PIPE,
            text=True,
        )
    except CalledProcessError:
        return
    src = str(Path(output.strip("\n"), "src"))
    if src not in sys.path:
        sys.path.insert(0, src)


_ = _add_src_to_sys_path()

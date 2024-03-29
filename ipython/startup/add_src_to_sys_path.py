from __future__ import annotations

import sys
from contextlib import suppress
from pathlib import Path
from subprocess import PIPE, CalledProcessError, check_output


def _add_src_to_sys_path() -> None:
    output = check_output(
        ["git", "rev-parse", "--show-toplevel"],  # noqa: S603, S607
        stderr=PIPE,
        text=True,
    )
    src = str(Path(output.strip("\n"), "src"))
    if src not in sys.path:
        sys.path.insert(0, src)


with suppress(CalledProcessError):
    _ = _add_src_to_sys_path()

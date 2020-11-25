from __future__ import annotations

from pathlib import Path


with open(
    Path(__file__).resolve().parent.parent.joinpath("imports.py"),
) as file:
    for line in file:
        try:
            code = compile(line.rstrip("\n"), "", "exec")
        except SyntaxError:
            pass
        else:
            try:
                exec(code)  # noqa: S102
            except ModuleNotFoundError:
                pass

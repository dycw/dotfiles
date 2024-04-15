from __future__ import annotations  # noqa: INP001

from contextlib import suppress

with suppress(NameError):
    c = get_config()  # type: ignore[]  # noqa: F821


try:
    from jupyterlab_code_formatter.formatters import (  # type: ignore[]
        SERVER_FORMATTERS,
        CommandLineFormatter,
    )
except ModuleNotFoundError:
    pass
else:

    class MyRuffFormat(CommandLineFormatter):
        def __init__(self) -> None:
            try:
                from ruff.__main__ import find_ruff_bin  # type: ignore[]

                ruff = find_ruff_bin()
            except (ImportError, FileNotFoundError):
                ruff = "ruff"
            self.command = [ruff, "format", "-"]

        @property
        def label(self) -> str:
            return "Apply `ruff format`"

    SERVER_FORMATTERS["my_ruff_format"] = MyRuffFormat()

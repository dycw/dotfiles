from __future__ import annotations  # noqa: INP001

from contextlib import suppress
from subprocess import run
from typing import Any

with suppress(NameError):
    c = get_config()  # type: ignore[]  # noqa: F821


try:
    from jupyterlab_code_formatter.formatters import (  # type: ignore[]
        SERVER_FORMATTERS,
        BaseFormatter,
        CommandLineFormatter,
        handle_line_ending_and_magic,
        logger,
    )
except ModuleNotFoundError:
    pass
else:

    class MyRuffCheck(CommandLineFormatter):
        @property
        def label(self) -> str:
            return "Apply `ruff check`"

        def __init__(self) -> None:
            try:
                from ruff.__main__ import find_ruff_bin  # type: ignore[]

                ruff_command = find_ruff_bin()
            except (ImportError, FileNotFoundError):
                ruff_command = "ruff"
            self.command = [ruff_command, "--fix-only", "--unsafe-fixes", "check", "-"]

    SERVER_FORMATTERS["my_ruff_check"] = MyRuffCheck()

    class RuffFormatFormatter(BaseFormatter):
        label = "Apply Ruff Format Formatter - Confirmed working for 0.1.3"

        def __init__(self) -> None:
            try:
                from ruff.__main__ import find_ruff_bin  # type: ignore[]

                self.ruff_bin = find_ruff_bin()
            except (ImportError, FileNotFoundError):
                self.ruff_bin = "ruff"

        @property
        def importable(self) -> bool:
            return True

        @handle_line_ending_and_magic
        def format_code(
            self,
            code: str,
            _notebook: bool,  # noqa: FBT001
            args: list[str] | None = None,
            **_kwargs: Any,
        ) -> str:
            _ = (_notebook, _kwargs)
            if args is None:
                args = []
            process = run(
                [self.ruff_bin, "format", "-"],  # noqa: S603
                input=code,
                capture_output=True,
                text=True,
                check=False,
            )
            if process.stderr:
                logger.info(process.stderr)
                return code
            return process.stdout

    SERVER_FORMATTERS["ruff_format"] = RuffFormatFormatter()

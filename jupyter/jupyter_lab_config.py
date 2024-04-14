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
        handle_line_ending_and_magic,
        logger,
    )
except ModuleNotFoundError:
    pass
else:
    RUFF_OPTIONS = [
        "--select=ALL",
        "--ignore=W191",  # tab-indentation
        "--ignore=E111",  # indentation-with-invalid-multiple
        "--ignore=E114",  # indentation-with-invalid-multiple-comment
        "--ignore=E117",  # over-indented
        "--ignore=D206",  # indent-with-spaces
        "--ignore=D300",  # triple-single-quotes
        "--ignore=Q000",  # bad-quotes-inline-string
        "--ignore=Q001",  # bad-quotes-multiline-string
        "--ignore=Q002",  # bad-quotes-docstring
        "--ignore=Q003",  # avoidable-escaped-quote
        "--ignore=COM812",  # missing-trailing-comma
        "--ignore=COM819",  # prohibited-trailing-comma
        "--ignore=ISC001",  # single-line-implicit-string-concatenation
        "--ignore=ISC002",  # multi-line-implicit-string-concatenation
    ]

    class MyRuffCheck(BaseFormatter):
        label = "Apply `ruff check`"

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
                [  # noqa: S603
                    self.ruff_bin,
                    "check",
                    "--fix-only",
                    "--unsafe-fixes",
                    *RUFF_OPTIONS,
                    "-",
                ],
                input=code,
                capture_output=True,
                text=True,
                check=False,
            )
            if process.stderr:
                logger.info(process.stderr)
                return code
            return process.stdout

    SERVER_FORMATTERS["my_ruff_check"] = MyRuffCheck()

    class RuffFormatFormatter(BaseFormatter):
        label = "Apply Ruff Format Formatter - Confirmed working for 0.1.3"

        def __init__(self) -> None:
            try:
                from ruff.__main__ import find_ruff_bin  # type: ignore[]

                self.ruff_bin = find_ruff_bin()
            except (ImportError, FileNotFoundError):
                self.ruff_bin = "ruff"

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

        @property
        def importable(self) -> bool:
            return True

    SERVER_FORMATTERS["ruff_format"] = RuffFormatFormatter()

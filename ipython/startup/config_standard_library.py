from __future__ import annotations

import datetime as dt
from contextlib import contextmanager
from contextlib import redirect_stdout
from logging import Formatter
from logging import getLogger
from logging import INFO
from logging import Logger
from logging import StreamHandler
from os import devnull
from pathlib import Path
from re import search
from sys import stdout
from tempfile import TemporaryDirectory
from timeit import default_timer
from typing import Any
from typing import Iterator
from typing import List
from typing import Optional


def _initialize_logger() -> Logger:
    formatter = Formatter(
        fmt="{asctime} {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
    )
    handler = StreamHandler(stdout)
    handler.setLevel(INFO)
    handler.setFormatter(formatter)
    logger = getLogger("timer")
    logger.addHandler(handler)
    logger.setLevel(INFO)
    return logger


_TIMER_LOGGER = _initialize_logger()


class TemporaryDirectoryPath(TemporaryDirectory):
    def __enter__(self: TemporaryDirectoryPath) -> Path:
        return Path(super().__enter__())


class _TimerCM:
    def __init__(self: _TimerCM, msg: Optional[str] = None) -> None:
        self._msg = msg

    def __enter__(self: _TimerCM) -> None:
        self._start = default_timer()
        if self._msg is None:
            _TIMER_LOGGER.info("[S.]")
        else:
            _TIMER_LOGGER.info(f"[S.] {self._msg}")

    def __exit__(
        self: _TimerCM,
        exc_type: Any,  # noqa: U100
        exc_val: Any,  # noqa: U100
        exc_tb: Any,  # noqa: U100
    ) -> None:
        elapsed = dt.timedelta(seconds=default_timer() - self._start)
        e_str = str(elapsed)
        if match := search(r"(.*\.\d{1})\d{5}$", e_str):
            e_str = match.group(1)
        if self._msg is None:
            _TIMER_LOGGER.info(f"[.F] t={e_str}")
        else:
            _TIMER_LOGGER.info(f"[.F] {self._msg}, t={e_str}")


class _TimerMeta(type):
    _timers: List[_TimerCM] = []

    def __enter__(cls: _TimerMeta) -> None:
        timer = _TimerCM()
        cls._timers.append(timer)
        timer.__enter__()

    def __exit__(
        cls: _TimerMeta,
        exc_type: Any,
        exc_val: Any,
        exc_tb: Any,
    ) -> None:
        last = cls._timers.pop()
        last.__exit__(exc_type, exc_val, exc_tb)


class timer(metaclass=_TimerMeta):
    def __init__(self: timer, msg: str) -> None:
        self.msg = msg

    def __enter__(self: timer) -> None:
        self._timer = _TimerCM(self.msg)
        self._timer.__enter__()

    def __exit__(self: timer, exc_type: Any, exc_val: Any, exc_tb: Any) -> None:
        self._timer.__exit__(exc_type, exc_val, exc_tb)


@contextmanager
def no_stdout() -> Iterator[None]:
    with open(devnull, mode="w") as null:
        with redirect_stdout(null):
            yield

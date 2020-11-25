from __future__ import annotations

from functools import partial
from pathlib import Path
from typing import Any
from typing import Callable
from typing import Dict
from typing import List
from typing import Optional
from typing import Union
from warnings import warn


try:
    from numpy import isinf
    from pandas import option_context
    from pandas import read_csv
    from pandas import Series
    from pandas import set_option
except ModuleNotFoundError:
    pass
else:
    _DEFAULT_MIN_MAX_ROWS, _DEFAULT_MAX_COLUMNS = 7, 100

    def _formatter(x: float, *, template: str) -> str:
        return format(x, template)

    def _get_float_formatter(dp: int) -> Callable[[float], str]:
        return partial(_formatter, template=f".{dp}f")

    set_option(
        "display.float_format",
        _get_float_formatter(5),
        "display.min_rows",
        _DEFAULT_MIN_MAX_ROWS,
        "display.max_rows",
        _DEFAULT_MIN_MAX_ROWS,
        "display.max_columns",
        _DEFAULT_MAX_COLUMNS,
    )

    class _ShowMeta(type):
        _contexts: List[option_context] = []

        def __enter__(cls: _ShowMeta) -> None:
            new = option_context(
                "display.min_rows",
                100,
                "display.max_rows",
                100,
            )
            cls._contexts.append(new)
            new.__enter__()

        def __exit__(
            cls: _ShowMeta,
            exc_type: Any,
            exc_val: Any,
            exc_tb: Any,
        ) -> None:
            last = cls._contexts.pop()
            last.__exit__(exc_type, exc_val, exc_tb)

    class show(metaclass=_ShowMeta):
        """Context manager which adjusts the display of NDFrames."""

        def __init__(
            self: show,
            *,
            dp: Optional[int] = None,
            rows: Union[int, float] = _DEFAULT_MIN_MAX_ROWS,
            columns: Union[int, float] = _DEFAULT_MAX_COLUMNS,
        ) -> None:
            float_format = None if dp is None else _get_float_formatter(dp)
            if isinstance(rows, int):
                rows_use: Optional[int] = rows
            else:
                rows_use = None if isinf(rows) else int(rows)
            if isinstance(columns, int):
                columns_use: Optional[int] = columns
            else:
                columns_use = None if isinf(columns) else int(columns)
            self._context = option_context(
                "display.float_format",
                float_format,
                "display.min_rows",
                rows_use,
                "display.max_rows",
                rows_use,
                "display.max_columns",
                columns_use,
            )

        def __enter__(self: show) -> None:
            self._context.__enter__()

        def __exit__(
            self: show,
            exc_type: Any,
            exc_val: Any,
            exc_tb: Any,
        ) -> None:
            self._context.__exit__(exc_type, exc_val, exc_tb)

    def accumulate_csv(path: Union[Path, str], data: Dict) -> None:
        try:
            from atomic_write_path import atomic_write_path
        except ImportError:
            warn("Package 'atomic_write_path' missing")
            atomic_write_path = None
        try:
            df = read_csv(path)
        except FileNotFoundError:

            def to_csv(path: Union[Path, str]) -> None:
                Series(data).to_frame().T.to_csv(path, index=False)

            if atomic_write_path is None:
                to_csv(path)
            else:
                with atomic_write_path(path) as temp:
                    to_csv(temp)
        else:

            def to_csv(path: Union[Path, str]) -> None:
                df.append(data, ignore_index=True).to_csv(path, index=False)

            if atomic_write_path is None:
                to_csv(path)
            else:
                with atomic_write_path(path, overwrite=True) as temp:
                    to_csv(temp)

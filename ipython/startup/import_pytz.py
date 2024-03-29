from __future__ import annotations

from contextlib import suppress

with suppress(ModuleNotFoundError):
    import pytz  # noqa: F401
    from pytz import (  # noqa: F401
        UTC,
    )

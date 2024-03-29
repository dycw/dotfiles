from __future__ import annotations

from contextlib import suppress

with suppress(ModuleNotFoundError):
    import loguru  # noqa: F401
    from loguru import (  # noqa: F401
        logger,
    )

from __future__ import annotations

from contextlib import suppress

with suppress(ModuleNotFoundError):
    import box  # noqa: F401
    from box import (  # noqa: F401
        Box,
    )

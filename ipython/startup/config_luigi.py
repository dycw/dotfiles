from __future__ import annotations

from typing import Iterable
from typing import Optional

try:
    from luigi import build
    from luigi import Task
except ModuleNotFoundError:
    pass
else:

    def build_if_not_complete(
        tasks: Iterable[Task],
        local_scheduler: bool = False,
        log_level: str = "INFO",
        workers: Optional[int] = None,
    ) -> None:
        """Build a set of Tasks with the local scheduler."""

        to_build = [task for task in tasks if not task.complete()]
        if to_build:
            build(
                to_build,
                local_scheduler=local_scheduler,
                log_level=log_level,
                **({} if workers is None else {"workers": workers}),
            )

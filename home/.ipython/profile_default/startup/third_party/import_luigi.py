from logging import INFO
from typing import Iterable
from typing import Optional
from typing import Union

import luigi  # noqa: F401
from luigi import BoolParameter  # noqa: F401
from luigi import build
from luigi import DictParameter  # noqa: F401
from luigi import EnumParameter  # noqa: F401
from luigi import ExternalTask  # noqa: F401
from luigi import FloatParameter  # noqa: F401
from luigi import IntParameter  # noqa: F401
from luigi import LocalTarget  # noqa: F401
from luigi import Task
from luigi import TaskParameter  # noqa: F401
from luigi import TupleParameter  # noqa: F401


def build_if_not_complete(
    tasks: Iterable[Task],
    local_scheduler: bool = False,
    log_level: Union[int, str] = INFO,
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

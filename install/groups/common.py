from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.constants import HOME
from install.lib import add_to_known_hosts
from install.utilities import symlink_if_given

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def setup_common(
    *, pdbrc: PathLike | None = None, psqlrc: PathLike | None = None
) -> None:
    _LOGGER.info("Setting up common...")
    add_to_known_hosts()
    symlink_if_given(HOME / ".pdbrc", pdbrc)
    symlink_if_given(HOME / ".psqlrc", psqlrc)


__all__ = ["setup_common"]

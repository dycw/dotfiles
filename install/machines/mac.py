from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.machines.common import setup_common

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def setup_mac(
    *, git_config: PathLike | None = None, git_ignore: PathLike | None = None
) -> None:
    _LOGGER.info("Setting up Mac...")
    setup_common(git_config=git_config, git_ignore=git_ignore)
    install_fish()  # after brew
    # keyboard international
    # mouse up/down


__all__ = ["setup_mac"]

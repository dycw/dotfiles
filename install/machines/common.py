from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.lib import add_to_known_hosts, install_git

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def setup_common(
    *, git_config: PathLike | None = None, git_ignore: PathLike | None = None
) -> None:
    _LOGGER.info("Setting up common...")
    add_to_known_hosts()
    install_git(config=git_config, ignore=git_ignore)


__all__ = ["setup_common"]

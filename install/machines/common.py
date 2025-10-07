from __future__ import annotations

from logging import getLogger

from install.lib import add_to_known_hosts, install_git

_LOGGER = getLogger(__name__)


def setup_common() -> None:
    _LOGGER.info("Setting up common...")
    add_to_known_hosts()
    install_git(config=True)


__all__ = ["setup_common"]

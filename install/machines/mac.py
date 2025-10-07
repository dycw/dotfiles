from __future__ import annotations

from logging import getLogger

from install.machines.common import setup_common

_LOGGER = getLogger(__name__)


def setup_mac() -> None:
    _LOGGER.info("Setting up Mac...")
    setup_common()
    # keyboard international


__all__ = ["setup_mac"]

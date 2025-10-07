#!/usr/bin/env python3
from logging import getLogger

_LOGGER = getLogger(__name__)


def setup_macbook() -> None:
    _LOGGER.info("Setting up Macbook remotely...")

#!/usr/bin/env python3
from logging import basicConfig, getLogger

_LOGGER = getLogger(__name__)


def _main() -> None:
    _LOGGER.info("Setting up Macbook...")


if __name__ == "__main__":
    basicConfig(
        format="{asctime} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="INFO",
    )
    _main()

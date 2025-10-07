#!/usr/bin/env python3
from logging import basicConfig, getLogger

_LOGGER = getLogger(__name__)


def main() -> None:
    _LOGGER.info("Setting up Macbook...")


print("this is outside")


if __name__ == "__main__":
    basicConfig(
        format="{asctime} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="INFO",
    )
    main()


print("this is outside / after")

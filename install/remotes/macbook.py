#!/usr/bin/env python3
from __future__ import annotations

from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from dataclasses import dataclass
from logging import basicConfig, getLogger
from pathlib import Path
from subprocess import DEVNULL, check_call
from tempfile import TemporaryDirectory

#### this script can only contain std-lib imports #############################

_LOGGER = getLogger(__name__)


@dataclass(order=True, unsafe_hash=True, kw_only=True, slots=True)
class _Settings:
    verbose: bool

    @classmethod
    def parse(cls) -> _Settings:
        parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
        _ = parser.add_argument(
            "-ve", "--verbose", action="store_true", help="Verbose mode."
        )
        return _Settings(**vars(parser.parse_args()))


def _main(*, verbose: bool = False) -> None:
    _LOGGER.info("Setting up Macbook remotely...")
    with TemporaryDirectory() as _temp_dir:
        temp_dir = Path(_temp_dir)
        _LOGGER.info("Cloning repo...")
        url = "https://github.com/dycw/dotfiles.git"
        dotfiles = temp_dir / "dotfiles"
        _ = check_call(
            f"git clone {url} {dotfiles}", stdout=DEVNULL, stderr=DEVNULL, shell=True
        )
        _LOGGER.info("Changing branch...")
        _ = check_call(  # TEMPORARY!
            "git checkout re-organize",
            stdout=DEVNULL,
            stderr=DEVNULL,
            shell=True,
            cwd=dotfiles,
        )
        cmd = "python3 -m install.machines.macbook"
        if verbose:
            cmd = f"{cmd} -v"
        _LOGGER.info("Running %r...", cmd)
        _ = check_call(cmd, shell=True, cwd=dotfiles)


if __name__ == "__main__":
    settings = _Settings.parse()
    basicConfig(
        format="{asctime} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="DEBUG" if settings.verbose else "INFO",
    )
    _main()

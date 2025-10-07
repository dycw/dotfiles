#!/usr/bin/env python3
from logging import basicConfig, getLogger
from pathlib import Path
from subprocess import DEVNULL, check_call
from tempfile import TemporaryDirectory

#### this script can only contain std-lib imports #############################

_LOGGER = getLogger(__name__)


def _main() -> None:
    _LOGGER.info("Setting up Macbook remotely...")
    with TemporaryDirectory() as _temp_dir:
        temp_dir = Path(_temp_dir)
        _LOGGER.info("Cloning repo...")
        url = "https://github.com/dycw/dotfiles.git"
        dotfiles = temp_dir / "dotfiles"
        _ = check_call(
            f"git clone {url} {dotfiles}", stdout=DEVNULL, stderr=DEVNULL, shell=True
        )
        _ = check_call(  # TEMPORARY!
            "git checkout re-organize",
            stdout=DEVNULL,
            stderr=DEVNULL,
            shell=True,
            cwd=dotfiles,
        )
        _ = check_call("python3 -m install.machines.macbook", shell=True, cwd=dotfiles)


if __name__ == "__main__":
    basicConfig(
        format="{asctime} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="INFO",
    )
    _main()

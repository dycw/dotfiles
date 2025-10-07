#!/usr/bin/env python3
from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from dataclasses import dataclass
from logging import basicConfig, getLogger
from pathlib import Path
from subprocess import DEVNULL, check_call
from tempfile import TemporaryDirectory

_LOGGER = getLogger(__name__)


@dataclass(order=True, unsafe_hash=True, kw_only=True, slots=True)
class _Settings:
    remote: bool = False

    @classmethod
    def parse(cls) -> "_Settings":
        parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
        _ = parser.add_argument(
            "-r",
            "--remote",
            action="store_true",
            help="Designate the script as being run remotely.",
        )
        return _Settings(**vars(parser.parse_args()))


def main(*, remote: bool = False) -> None:
    if remote:
        _LOGGER.info("Setting up Macbook remotely...")
        with TemporaryDirectory() as _temp_dir:
            temp_dir = Path(_temp_dir)
            _LOGGER.info("Cloning repo...")
            url = "https://github.com/dycw/dotfiles.git"
            dotfiles = temp_dir / "dotfiles"
            _ = check_call(
                f"git clone {url} {dotfiles}",
                stdout=DEVNULL,
                stderr=DEVNULL,
                shell=True,
            )
            _ = check_call(  # TEMPORARY!
                "git checkout re-organize",
                stdout=DEVNULL,
                stderr=DEVNULL,
                shell=True,
                cwd=dotfiles,
            )
            _ = check_call(
                "python3 -m install.machines.macbook", shell=True, cwd=dotfiles
            )
    else:
        _LOGGER.info("Setting up Macbook...")


if __name__ == "__main__":
    basicConfig(
        format="{asctime} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="INFO",
    )
    settings = _Settings.parse()
    main(remote=settings.remote)

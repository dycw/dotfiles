#!/usr/bin/env python3
from __future__ import annotations

from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from dataclasses import dataclass
from logging import basicConfig, getLogger
from typing import TYPE_CHECKING

from install.constants import (
    REPO_STARSHIP_TOML,
    REPO_TMUX_CONF_LOCAL,
    REPO_TMUX_CONF_OH_MY_TMUX,
)
from install.groups.mac import setup_mac
from install.lib import install_dropbox, install_zoom

if TYPE_CHECKING:
    from install.types import PathLike

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


def _setup_macbook(*, glab_config_yml: PathLike | None = None) -> None:
    _LOGGER.info("Setting up MacBook...")
    setup_mac(
        glab_config_yml=glab_config_yml,
        starship_toml=REPO_STARSHIP_TOML,
        tmux_conf_oh_my_tmux=REPO_TMUX_CONF_OH_MY_TMUX,
        tmux_conf_local=REPO_TMUX_CONF_LOCAL,
    )
    install_dropbox()
    install_zoom()


if __name__ == "__main__":
    settings = _Settings.parse()
    basicConfig(
        format="{asctime} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="DEBUG" if settings.verbose else "INFO",
    )
    _setup_macbook()

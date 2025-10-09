#!/usr/bin/env python3
from __future__ import annotations

from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from dataclasses import dataclass
from logging import basicConfig, getLogger

from install.constants import (
    FISH_CONFIG,
    FISH_ENV,
    FISH_GIT,
    FISH_WORK,
    FZF_FISH,
    GIT_CONFIG,
    GIT_IGNORE,
    NVIM,
    PDBRC,
    PSQLRC,
    RIPGREPRC,
    SSH_CONFIG,
    STARSHIP_TOML,
    TMUX_CONF_LOCAL,
    TMUX_CONF_OH_MY_TMUX,
    WEZTERM_LUA,
)
from install.groups.linux import setup_linux
from install.lib import install_spotify

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


def _setup_swift() -> None:
    _LOGGER.info("Setting up Swift...")
    setup_linux(
        fish_config=FISH_CONFIG,
        fish_env=FISH_ENV,
        fish_git=FISH_GIT,
        fish_work=FISH_WORK,
        fzf_fish=FZF_FISH,
        git_config=GIT_CONFIG,
        git_ignore=GIT_IGNORE,
        nvim_dir=NVIM,
        pdbrc=PDBRC,
        psqlrc=PSQLRC,
        ripgreprc=RIPGREPRC,
        ssh_config=SSH_CONFIG,
        starship_toml=STARSHIP_TOML,
        tmux_conf_oh_my_tmux=TMUX_CONF_OH_MY_TMUX,
        tmux_conf_local=TMUX_CONF_LOCAL,
        wezterm_lua=WEZTERM_LUA,
    )
    install_spotify()


if __name__ == "__main__":
    settings = _Settings.parse()
    basicConfig(
        format="{asctime} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="DEBUG" if settings.verbose else "INFO",
    )
    _setup_swift()

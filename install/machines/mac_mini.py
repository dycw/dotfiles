#!/usr/bin/env python3
from __future__ import annotations

from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from dataclasses import dataclass
from logging import basicConfig, getLogger

from install.constants import (
    FD_IGNORE,
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
    STARSHIP_TOML,
    TMUX_CONF_LOCAL,
    TMUX_CONF_OH_MY_TMUX,
    WEZTERM_LUA,
)
from install.groups.mac import setup_mac
from install.lib import (
    install_dropbox,
    install_postico,
    install_protonvpn,
    install_spotify,
    install_transmission,
    install_vlc,
    install_vs_code,
    install_whatsapp,
    install_zoom,
)

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


def _setup_mac_mini() -> None:
    _LOGGER.info("Setting up Mac Mini...")
    setup_mac(
        fd_ignore=FD_IGNORE,
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
        starship_toml=STARSHIP_TOML,
        tmux_conf_oh_my_tmux=TMUX_CONF_OH_MY_TMUX,
        tmux_conf_local=TMUX_CONF_LOCAL,
        wezterm_lua=WEZTERM_LUA,
    )
    install_dropbox()
    install_postico()
    install_protonvpn()
    install_spotify()
    install_transmission()
    install_vlc()
    install_vs_code()
    install_whatsapp()
    install_zoom()


if __name__ == "__main__":
    settings = _Settings.parse()
    basicConfig(
        format="{asctime} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="DEBUG" if settings.verbose else "INFO",
    )
    _setup_mac_mini()

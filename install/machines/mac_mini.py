#!/usr/bin/env python3
from __future__ import annotations

from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from dataclasses import dataclass
from logging import basicConfig, getLogger

from install.constants import (
    REPO_BOTTOM_TOML,
    REPO_FD_IGNORE,
    REPO_FISH_CONFIG,
    REPO_FISH_ENV,
    REPO_FISH_GIT,
    REPO_FISH_WORK,
    REPO_FZF_FISH,
    REPO_GIT_CONFIG,
    REPO_GIT_IGNORE,
    REPO_NVIM,
    REPO_PDBRC,
    REPO_PSQLRC,
    REPO_RIPGREPRC,
    REPO_STARSHIP_TOML,
    REPO_TMUX_CONF_LOCAL,
    REPO_TMUX_CONF_OH_MY_TMUX,
    REPO_WEZTERM_LUA,
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
        bottom_toml=REPO_BOTTOM_TOML,
        fd_ignore=REPO_FD_IGNORE,
        fish_config=REPO_FISH_CONFIG,
        fish_env=REPO_FISH_ENV,
        fish_git=REPO_FISH_GIT,
        fish_work=REPO_FISH_WORK,
        fzf_fish=REPO_FZF_FISH,
        git_config=REPO_GIT_CONFIG,
        git_ignore=REPO_GIT_IGNORE,
        nvim_dir=REPO_NVIM,
        pdbrc=REPO_PDBRC,
        psqlrc=REPO_PSQLRC,
        ripgreprc=REPO_RIPGREPRC,
        starship_toml=REPO_STARSHIP_TOML,
        tmux_conf_oh_my_tmux=REPO_TMUX_CONF_OH_MY_TMUX,
        tmux_conf_local=REPO_TMUX_CONF_LOCAL,
        wezterm_lua=REPO_WEZTERM_LUA,
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

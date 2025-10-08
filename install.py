#!/usr/bin/env python3
from logging import getLogger

# constants


_LOGGER = getLogger(__name__)


# library


def install_npm() -> None:
    # this is for neovim
    if have_command("npm"):
        _LOGGER.debug("'npm' is already installed")
        return
    _LOGGER.info("Installing 'npm'...")
    apt_install("nodejs", "npm")


# main


def _setup_debian(settings: _Settings, /) -> None:
    install_npm()
    install_python3_13_venv()

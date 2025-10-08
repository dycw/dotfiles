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


def install_python3_13_venv() -> None:
    # this is for neovim
    if have_command("python3.13"):
        _LOGGER.debug(
            "'python3.13' is already installed (and presumably so is 'python3.13-venv'"
        )
        return
    _LOGGER.info("Installing 'python3.13-venv'...")
    apt_install("python3.13-venv")


# main


def _setup_debian(settings: _Settings, /) -> None:
    install_npm()
    install_python3_13_venv()

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


def install_wezterm() -> None:
    if have_command("wezterm"):
        _LOGGER.debug("'wezterm' is already installed")
    else:
        install_curl()
        _LOGGER.info("Installing 'wezterm'...")
        run_commands(
            "curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg",
            "echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list",
            "sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg",
        )
        apt_install("wezterm")
    symlink("~/.config/wezterm/wezterm.lua", f"{_get_script_dir()}/wezterm/wezterm.lua")


def install_zoom() -> None:
    if have_command("zoom"):
        _LOGGER.debug("'zoom' is already installed")
        return
    _LOGGER.info("Installing 'zoom'...")
    apt_install("libxcb-xinerama0", "libxcb-xtest0", "libxcb-cursor0")
    _dpkg_install("zoom_amd64.deb")


# main


def _setup_debian(settings: _Settings, /) -> None:
    install_npm()
    install_python3_13_venv()
    if settings.zoom:
        install_zoom()

    if settings.spotify:
        install_spotify()  # after curl
    if settings.tailscale:
        install_tailscale()  # after curl
    if settings.wezterm:
        install_wezterm()  # after curl

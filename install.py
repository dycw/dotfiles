#!/usr/bin/env python3
from logging import getLogger
from pathlib import Path
from tempfile import TemporaryDirectory
from zipfile import ZipFile

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


def install_spotify() -> None:
    if have_command("spotify"):
        _LOGGER.debug("'spotify' is already installed")
        return
    install_curl()
    _LOGGER.info("Installing 'spotify'...")
    run_commands(
        "curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg",
        'echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list',
    )
    apt_install("spotify-client")


def install_tailscale() -> None:
    if have_command("tailscale"):
        _LOGGER.debug("'tailscale' is already installed")
        return
    _LOGGER.info("Installing 'tailscale'...")
    install_curl()
    run_commands("curl -fsSL https://tailscale.com/install.sh | sh")


def install_tmux() -> None:
    if have_command("tmux"):
        _LOGGER.debug("'tmux' is already installed")
    else:
        _LOGGER.info("Installing 'tmux'...")
        apt_install("tmux")
    _update_submodules()
    for filename_from, filename_to in [
        ("tmux.conf.local", "tmux.conf.local"),
        ("tmux.conf", ".tmux/.tmux.conf"),
    ]:
        symlink(
            f"~/.config/tmux/{filename_from}", f"{_get_script_dir()}/tmux/{filename_to}"
        )


def install_vim() -> None:
    if have_command("vim"):
        _LOGGER.debug("'vim' is already installed")
        return
    _LOGGER.info("Installing 'vim'...")
    apt_install("vim")


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


def _setup_sshd() -> None:
    path = full_path("/etc/ssh/sshd_config")
    for from_, to in [
        ("#PermitRootLogin prohibit-password", "PermitRootLogin no"),
        ("#PubkeyAuthentication yes", "PubkeyAuthentication yes"),
        ("#PasswordAuthentication yes", "PasswordAuthentication no"),
    ]:
        _replace_line(path, from_, to)


# utilities


# main


def _setup_mac(settings: _Settings, /) -> None:
    if settings.bump_my_version:
        install_bump_my_version()  # after uv
    if settings.pre_commit:
        install_pre_commit()  # after uv
    if settings.pyright:
        install_pyright()  # after uv


def _setup_debian(settings: _Settings, /) -> None:
    install_neovim(config=f"{_get_script_dir()}/nvim")
    install_npm()
    install_python3_13_venv()
    install_starship(starship_toml=f"{_get_script_dir()}/starship/starship.toml")
    _setup_sshd()
    if settings.ripgrep:
        install_ripgrep(config=True)
    if settings.rsync:
        install_rsync()
    if settings.shellcheck:
        install_shellcheck()
    if settings.shfmt:
        install_shfmt()
    if settings.ssh_keys is not None:
        _setup_ssh_keys(settings.ssh_keys)
    if settings.stylua:
        install_stylua()
    if settings.syncthing:
        install_syncthing()
    if settings.tmux:
        install_tmux()
    if settings.vim:
        install_vim()
    if settings.yq:
        install_yq()
    if settings.zoom:
        install_zoom()
    if settings.zoxide:
        install_zoxide()

    if settings.spotify:
        install_spotify()  # after curl
    if settings.tailscale:
        install_tailscale()  # after curl
    if settings.wezterm:
        install_wezterm()  # after curl

    if settings.bump_my_version:
        install_bump_my_version()  # after uv
    if settings.pre_commit:
        install_pre_commit()  # after uv
    if settings.pyright:
        install_pyright()  # after uv
    if settings.ruff:
        install_ruff()  # after uv

#!/usr/bin/env python3
# ruff: noqa: S602,S607
from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from dataclasses import dataclass
from logging import basicConfig, getLogger
from pathlib import Path
from shutil import which
from subprocess import check_call

# constants


_LOGGER = getLogger(__name__)


# settings


@dataclass(order=True, unsafe_hash=True, kw_only=True)
class _Settings:
    bottom: bool
    build_essential: bool
    fd_find: bool
    ripgrep: bool
    shellcheck: bool
    shfmt: bool
    tmux: bool
    verbose: bool
    zoom: bool

    @classmethod
    def parse(cls) -> "_Settings":
        parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
        parser.add_argument(
            "-bt", "--bottom", action="store_true", help="Install 'bottom'."
        )
        parser.add_argument(
            "-bu",
            "--build-essential",
            action="store_true",
            help="Install 'build-essential'.",
        )
        parser.add_argument(
            "-f", "--fd-find", action="store_true", help="Install 'fd-find'."
        )
        parser.add_argument(
            "-r", "--ripgrep", action="store_true", help="Install 'ripgrep'."
        )
        parser.add_argument(
            "-shc", "--shellcheck", action="store_true", help="Install 'shellcheck'."
        )
        parser.add_argument(
            "-shf", "--shfmt", action="store_true", help="Install 'shfmt'."
        )
        parser.add_argument("-t", "--tmux", action="store_true", help="Install 'tmux'.")
        parser.add_argument("-z", "--zoom", action="store_true", help="Install 'zoom'.")
        parser.add_argument(
            "-v", "--verbose", action="store_true", help="Verbose mode."
        )
        return _Settings(**vars(parser.parse_args()))


# script


def main(settings: _Settings, /) -> None:
    basicConfig(
        format="{asctime} | {levelname:8} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="DEBUG" if settings.verbose else "INFO",
    )
    _setup_shells()
    _install_curl()
    _install_git()
    _install_neovim()
    _install_starship()
    if settings.bottom:
        _install_bottom()
    if settings.build_essential():
        _install_build_essential()
    if settings.fd_find:
        _install_fd_find()
    if settings.ripgrep:
        _install_ripgrep()
    if settings.shellcheck:
        _install_shellcheck()
    if settings.shfmt:
        _install_shfmt()
    if settings.tmux:
        _install_tmux()
    if settings.zoom:
        _install_zoom()

    _install_uv()  # after curl

    _install_bump_my_version()  # after uv
    _install_pre_commit()  # after uv
    _install_pyright()  # after uv
    _install_ruff()  # after uv


def _install_bottom() -> None:
    if which("btm"):
        _LOGGER.debug("'btm' is already installed")
        return
    _LOGGER.info("Installing 'bottom'...")
    # curl + deb based, need to get latest version


def _install_build_essential() -> None:
    if which("cc"):
        _LOGGER.debug(
            "'cc' is already installed (already presumable so is 'build-essential'"
        )
        return
    _LOGGER.info("Installing 'build-essential'...")
    _apt_install("build-essential")


def _install_bump_my_version() -> None:
    _uv_tool_install("bump-my-version")


def _install_curl() -> None:
    if which("curl"):
        _LOGGER.debug("'curl' is already installed")
        return
    _LOGGER.info("Installing 'curl'...")
    _apt_install("curl")


def _install_fd_find() -> None:
    if which("fd"):
        _LOGGER.debug("'fd-find' is already installed")
        return
    _LOGGER.info("Installing 'fd-find'...")
    _apt_install("fd-find")


def _install_git() -> None:
    if which("git"):
        _LOGGER.debug("'git' is already installed")
    else:
        _LOGGER.info("Installing 'git'...")
        _apt_install("git")
    for filename in ["config", "ignore"]:
        _setup_symlink(
            f"~/.config/git/{filename}", f"{_get_script_dir()}/git/{filename}"
        )


def _install_neovim() -> None:
    if which("nvim"):
        _LOGGER.debug("'neovim' is already installed")
        return
    _LOGGER.info("Installing 'neovim'...")
    _apt_install("neovim")


def _install_ripgrep() -> None:
    if which("rg"):
        _LOGGER.debug("'ripgrep' is already installed")
        return
    _LOGGER.info("Installing 'ripgrep'...")
    _apt_install("ripgrep")


def _install_shellcheck() -> None:
    if which("shellcheck"):
        _LOGGER.debug("'shellcheck' is already installed")
        return
    _LOGGER.info("Installing 'shellcheck'...")
    _apt_install("shellcheck")


def _install_shfmt() -> None:
    if which("shfmt"):
        _LOGGER.debug("'shfmt' is already installed")
        return
    _LOGGER.info("Installing 'shfmt'...")
    _apt_install("shfmt")


def _install_starship() -> None:
    if which("starship"):
        _LOGGER.debug("'starship' is already installed")
        return
    _LOGGER.info("Installing 'starship'...")
    _apt_install("starship")


def _install_tmux() -> None:
    if which("tmux"):
        _LOGGER.debug("'tmux' is already installed")
    else:
        _LOGGER.info("Installing 'tmux'...")
        _apt_install("tmux")
    _update_submodules()
    for filename_from, filename_to in [
        ("tmux.conf.local", "tmux.conf.local"),
        ("tmux.conf", ".tmux/.tmux.conf"),
    ]:
        _setup_symlink(
            f"~/.config/tmux/{filename_from}", f"{_get_script_dir()}/tmux/{filename_to}"
        )


def _install_pre_commit() -> None:
    _uv_tool_install("pre-commit")


def _install_pyright() -> None:
    _uv_tool_install("pyright")


def _install_ruff() -> None:
    _uv_tool_install("ruff")


def _install_uv() -> None:
    if which("uv"):
        _LOGGER.debug("'uv' is already installed")
        return
    _install_curl()
    _LOGGER.info("Installing 'uv'...")
    check_call("curl -LsSf https://astral.sh/uv/install.sh | sh", shell=True)
    _append_to_file("~/.bashrc", '''export PATH="${HOME}${PATH:+:${PATH}}"''')
    check_call("source ~/.bashrc", shell=True)


def _install_zoom() -> None:
    if which("zoom"):
        _LOGGER.debug("'zoom' is already installed")
        return
    _LOGGER.info("Installing 'zoom'...")
    _apt_install(
        "libxcb-xinerama0",
        "libxcb-xtest0",
        "libxcb-cursor0",
    )
    check_call("sudo dpkg -i zoom_amd64.deb", shell=True)


def _setup_bash() -> None:
    for filename in ["bashrc", "bash_profile"]:
        _setup_symlink(f"~/.{filename}", f"{_get_script_dir()}/bash/{filename}")


def _setup_shells() -> None:
    _setup_bash()


# utilities


def _append_to_file(path: Path | str, line: str, /) -> None:
    path = _to_path(path)
    try:
        lines = path.read_text().splitlines()
    except FileNotFoundError:
        _LOGGER.info("Writing %r to %r...", line, str(path))
        with path.open(mode="w") as fh:
            _ = fh.write(f"{line}\n")
        return
    if any(line_i == line for line_i in lines):
        _LOGGER.debug("%r is already in %r", line, str(path))
        return
    _LOGGER.info("Appending %r to %r...", line, str(path))
    with path.open(mode="a") as fh:
        _ = fh.write(f"{line}\n")


def _apt_install(*packages: str) -> None:
    _LOGGER.info("Updating 'apt'...")
    check_call("sudo apt -y update", shell=True)
    desc = ", ".join(map(repr, packages))
    _LOGGER.info("Installing %s...", desc)
    joined = " ".join(packages)
    check_call(f"sudo apt -y install {joined}", shell=True)


def _get_script_dir() -> Path:
    return Path(__file__).parent


def _setup_symlink(path_from: Path | str, path_to: Path | str, /) -> None:
    path_from, path_to = map(_to_path, [path_from, path_to])
    if path_from.is_symlink and (path_from.resolve() == path_to.resolve()):
        _LOGGER.debug("%r -> %r already symlinked", str(path_from), str(path_to))
        return
    path_from.parent.mkdir(parents=True, exist_ok=True)
    if path_from.exists() or path_from.is_symlink():
        _LOGGER.info("Removing %r...", str(path_from))
        path_from.unlink()
    _LOGGER.info("Symlinking %r -> %r", str(path_from), str(path_to))
    path_from.symlink_to(path_to)


def _to_path(path: Path | str, /) -> Path:
    return Path(path).expanduser()


def _update_submodules() -> None:
    _LOGGER.info(
        "Updating submodules...",
    )
    check_call("git submodule update", shell=True)


def _uv_tool_install(tool: str, /) -> None:
    if which(tool):
        _LOGGER.debug("%r is already installed", tool)
        return
    _install_uv()
    _LOGGER.info("Installing %r...", tool)
    check_call(f"uv tool install {tool}", shell=True)


# main


main(_Settings.parse())

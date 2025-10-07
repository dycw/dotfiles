from __future__ import annotations

from logging import getLogger
from re import search
from typing import TYPE_CHECKING, assert_never

from install.constants import KNOWN_HOSTS
from install.enums import System
from install.utilities import apt_install, have_command, run_commands, symlink, touch

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def add_to_known_hosts() -> None:
    def run() -> None:
        _LOGGER.info("Adding 'github.com' to known hosts...")
        run_commands(f"ssh-keyscan github.com >> {KNOWN_HOSTS}")

    try:
        contents = KNOWN_HOSTS.read_text()
    except FileNotFoundError:
        touch(KNOWN_HOSTS)
        run()
        return
    if any(search(r"github\.com", line) for line in contents.splitlines()):
        _LOGGER.debug("Known hosts already contains 'github.com'")
        return
    run()


def install_brew() -> None:
    if have_command("brew"):
        _LOGGER.debug("'brew' is already installed")
        return
    _LOGGER.info("Installing 'brew'...")
    run_commands(
        "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash",
        env={"NONINTERACTIVE": "1"},
    )


def install_curl() -> None:
    if have_command("curl"):
        _LOGGER.debug("'curl' is already installed")
        return
    match System.identify():
        case System.mac:
            msg = "Mac should already have 'curl' installed"
            raise RuntimeError(msg)
        case System.linux:
            apt_install("git")
        case never:
            assert_never(never)


def install_git(
    *, config: PathLike | None = None, ignore: PathLike | None = None
) -> None:
    if have_command("git"):
        _LOGGER.debug("'git' is already installed")
    else:
        _LOGGER.info("Installing 'git'...")
        match System.identify():
            case System.mac:
                msg = "Mac should already have 'git' installed"
                raise RuntimeError(msg)
            case System.linux:
                apt_install("git")
            case never:
                assert_never(never)
    for filename, path_to in [("config", config), ("ignore", ignore)]:
        if path_to is not None:
            symlink(f"~/.config/git/{filename}", path_to)


__all__ = ["install_brew", "install_curl", "install_git"]

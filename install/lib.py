from __future__ import annotations

from logging import getLogger
from os import environ
from re import search
from typing import TYPE_CHECKING, assert_never

from install.constants import KNOWN_HOSTS, XDG_CONFIG_HOME
from install.enums import System
from install.utilities import (
    apt_install,
    brew_install,
    check_for_commands,
    copyfile,
    full_path,
    have_command,
    run_commands,
    symlink_many_if_given,
    touch,
)

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


def install_fish(
    *,
    config: PathLike | None = None,
    env: PathLike | None = None,
    git: PathLike | None = None,
    work: PathLike | None = None,
) -> None:
    if have_command("fish"):
        _LOGGER.debug("'fish' is already installed")
    else:
        _LOGGER.info("Installing 'fish'...")
        match System.identify():
            case System.mac:
                brew_install("fish")
            case System.linux:
                check_for_commands("curl")
                run_commands(
                    "echo 'deb http://download.opensuse.org/repositories/shells:/fish/Debian_13/ /' | sudo tee /etc/apt/sources.list.d/shells:fish.list",
                    "curl -fsSL https://download.opensuse.org/repositories/shells:fish/Debian_13/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish.gpg > /dev/null",
                )
                apt_install("fish")
            case never:
                assert_never(never)
    if search(r"/fish$", environ["SHELL"]):
        _LOGGER.debug("'fish' is already the default shell")
    else:
        _LOGGER.info("Setting 'fish' as the default shell...")
        _ = run_commands("chsh -s $(which fish)")
    fish = XDG_CONFIG_HOME / "fish"
    conf_d = fish / "conf.d"
    symlink_many_if_given(
        (fish / "config.fish", config),
        (conf_d / "0-env.fish", env),
        (conf_d / "git.fish", git),
        (conf_d / "work.fish", work),
    )


def install_fzf(*, fzf_fish: PathLike | None = None) -> None:
    if have_command("fzf"):
        _LOGGER.debug("'fzf' is already installed")
    else:
        _LOGGER.info("Installing 'fzf'...")
        match System.identify():
            case System.mac:
                brew_install("fzf")
            case System.linux:
                apt_install("fzf")
            case never:
                assert_never(never)
    if fzf_fish is not None:
        for path in (full_path(fzf_fish) / "functions").iterdir():
            copyfile(path, XDG_CONFIG_HOME / f"functions/{path.name}")


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
    git = full_path("~/.config/git")
    symlink_many_if_given((git / "config", config), (git / "ignore", ignore))


__all__ = ["install_brew", "install_curl", "install_fish", "install_fzf", "install_git"]

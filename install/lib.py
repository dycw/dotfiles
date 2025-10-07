from __future__ import annotations

from logging import getLogger
from os import environ
from re import search
from typing import TYPE_CHECKING, assert_never

from install.constants import HOME, KNOWN_HOSTS, LOCAL_BIN, XDG_CONFIG_HOME
from install.enums import System
from install.utilities import (
    apt_install,
    brew_install,
    check_for_commands,
    copyfile,
    dpkg_install,
    full_path,
    have_command,
    run_commands,
    symlink,
    symlink_if_given,
    symlink_many_if_given,
    touch,
    yield_github_latest_download,
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


def install_age() -> None:
    if have_command("age"):
        _LOGGER.debug("'age' is already installed")
        return
    _LOGGER.info("Installing 'age'...")
    match System.identify():
        case System.mac:
            brew_install("age")
        case System.linux:
            apt_install("age")
        case never:
            assert_never(never)


def install_bat() -> None:
    match System.identify():
        case System.mac:
            if have_command("bat"):
                _LOGGER.debug("'bat' is already installed")
                return
            _LOGGER.info("Installing 'bat'...")
            brew_install("bat")
        case System.linux:
            if have_command("batcat"):
                _LOGGER.debug("'bat' is already installed")
            else:
                _LOGGER.info("Installing 'bat'...")
                apt_install("bat")
            symlink(LOCAL_BIN / "bat", "/usr/bin/batcat")
        case never:
            assert_never(never)


def install_bottom(*, bottom_toml: PathLike | None = None) -> None:
    if have_command("btm"):
        _LOGGER.debug("'bottom' is already installed")
    else:
        _LOGGER.info("Installing 'bottom'...")
        match System.identify():
            case System.mac:
                brew_install("bottom")
            case System.linux:
                with yield_github_latest_download(
                    "ClementTsang", "bottom", "bottom_${tag}-1_amd64.deb"
                ) as path:
                    dpkg_install(path)
            case never:
                assert_never(never)
    symlink_if_given(XDG_CONFIG_HOME / "bottom/bottom.toml", bottom_toml)


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
            copyfile(path, XDG_CONFIG_HOME / f"fish/functions/{path.name}")


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
    git = XDG_CONFIG_HOME / "git"
    symlink_many_if_given((git / "config", config), (git / "ignore", ignore))


def install_uv() -> None:
    if have_command("uv"):
        _LOGGER.debug("'uv' is already installed")
        return
    check_for_commands("curl")
    _LOGGER.info("Installing 'uv'...")
    run_commands("curl -LsSf https://astral.sh/uv/install.sh | sh")


def setup_pdb(*, pdbrc: PathLike | None = None) -> None:
    symlink_if_given(HOME / ".pdbrc", pdbrc)


def setup_psqlrc(*, pdbrc: PathLike | None = None) -> None:
    symlink_if_given(HOME / ".psqlrc", psqlrc)


__all__ = [
    "install_age",
    "install_bat",
    "install_brew",
    "install_curl",
    "install_fish",
    "install_fzf",
    "install_git",
    "install_uv",
    "setup_pdb",
    "setup_psqlrc",
]

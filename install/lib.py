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
    uv_tool_install,
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


def install_build_essential() -> None:
    if have_command("cc"):
        _LOGGER.debug(
            "'cc' is already installed (and presumably so is 'build-essential'"
        )
        return
    _LOGGER.info("Installing 'build-essential'...")
    apt_install("build-essential")


def install_bump_my_version() -> None:
    if have_command("bump-my-version"):
        _LOGGER.debug("'bump-my-version' is already installed")
        return
    _LOGGER.info("Installing 'bump-my-version'...")
    match System.identify():
        case System.mac:
            brew_install("bump-my-version")
        case System.linux:
            uv_tool_install("bump-my-version")
        case never:
            assert_never(never)


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
    _LOGGER.info("Installing 'curl'...")
    apt_install("git")


def install_delta() -> None:
    if have_command("delta"):
        _LOGGER.debug("'delta' is already installed")
        return
    _LOGGER.info("Installing 'delta'...")
    match System.identify():
        case System.mac:
            brew_install("git-delta")
        case System.linux:
            apt_install("git-delta")
        case never:
            assert_never(never)


def install_docker() -> None:
    if have_command("docker"):
        _LOGGER.debug("'docker' is already installed")
        return
    _LOGGER.info("Installing 'docker'...")
    packages = [
        "docker.io",
        "docker-doc",
        "docker-compose",
        "podman-docker",
        "containerd",
        "runc",
    ]
    run_commands(*(f"sudo apt-get remove {p}" for p in packages))
    apt_install("ca-certificates", "curl")
    run_commands(
        "sudo install -m 0755 -d /etc/apt/keyrings",
        "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",
        "sudo chmod a+r /etc/apt/keyrings/docker.asc",
        'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null',
    )
    apt_install(
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin",
    )
    run_commands("sudo usermod -aG docker $USER")


def install_direnv(
    *, direnv_toml: PathLike | None = None, direnvrc: PathLike | None = None
) -> None:
    if have_command("direnv"):
        _LOGGER.debug("'direnv' is already installed")
    else:
        _LOGGER.info("Installing 'direnv'...")
        match System.identify():
            case System.mac:
                brew_install("direnv")
            case System.linux:
                apt_install("direnv")
            case never:
                assert_never(never)
    direnv = XDG_CONFIG_HOME / "direnv"
    symlink_many_if_given(
        (direnv / "direnv.toml", direnv_toml), (direnv / "direnvrc", direnvrc)
    )


def install_dust() -> None:
    if have_command("dust"):
        _LOGGER.debug("'dust' is already installed")
        return
    _LOGGER.info("Installing 'delta'...")
    match System.identify():
        case System.mac:
            brew_install("dust")
        case System.linux:
            apt_install("du-dust")
        case never:
            assert_never(never)


def install_eza() -> None:
    if have_command("eza"):
        _LOGGER.debug("'eza' is already installed")
        return
    _LOGGER.info("Installing 'eza'...")
    match System.identify():
        case System.mac:
            brew_install("eza")
        case System.linux:
            apt_install("eza")
        case never:
            assert_never(never)


def install_fd_find(*, ignore: PathLike | None = None) -> None:
    if have_command("fdfind"):
        _LOGGER.debug("'fd-find' is already installed")
    else:
        _LOGGER.info("Installing 'fd-find'...")
        match System.identify():
            case System.mac:
                brew_install("fd")
            case System.linux:
                apt_install("fd-find")
            case never:
                assert_never(never)
    symlink_if_given(XDG_CONFIG_HOME / "fd/ignore", ignore)


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


def install_sops(*, age_secret_key: PathLike | None = None) -> None:
    if have_command("sops"):
        _LOGGER.debug("'sops' is already installed")
    else:
        _LOGGER.info("Installing 'sops'...")
        match System.identify():
            case System.mac:
                brew_install("sops")
            case System.linux:
                path_to = LOCAL_BIN / "sops"
                with yield_github_latest_download(
                    "getsops", "sops", "sops-${tag}.linux.amd64"
                ) as binary:
                    copyfile(binary, path_to, executable=True)
            case never:
                assert_never(never)
    symlink_if_given(XDG_CONFIG_HOME / "sops/age/keys.txt", age_secret_key)


def install_uv() -> None:
    if have_command("uv"):
        _LOGGER.debug("'uv' is already installed")
        return
    _LOGGER.info("Installing 'uv'...")
    match System.identify():
        case System.mac:
            brew_install("uv")
        case System.linux:
            check_for_commands("curl")
            run_commands("curl -LsSf https://astral.sh/uv/install.sh | sh")
        case never:
            assert_never(never)


def setup_pdb(*, pdbrc: PathLike | None = None) -> None:
    symlink_if_given(HOME / ".pdbrc", pdbrc)


def setup_psql(*, psqlrc: PathLike | None = None) -> None:
    symlink_if_given(HOME / ".psqlrc", psqlrc)


__all__ = [
    "install_age",
    "install_bat",
    "install_brew",
    "install_build_essential",
    "install_bump_my_version",
    "install_curl",
    "install_delta",
    "install_direnv",
    "install_docker",
    "install_dust",
    "install_eza",
    "install_fd_find",
    "install_fish",
    "install_fzf",
    "install_git",
    "install_sops",
    "install_uv",
    "setup_pdb",
    "setup_psql",
]

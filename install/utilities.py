from __future__ import annotations

import shutil
import tempfile
from collections.abc import Iterator
from contextlib import contextmanager, suppress
from logging import getLogger
from os import environ, getenv, geteuid
from pathlib import Path
from stat import S_IXUSR
from string import Template
from subprocess import check_call, check_output
from typing import TYPE_CHECKING
from urllib.parse import urlparse
from urllib.request import urlopen

if TYPE_CHECKING:
    from collections.abc import Iterator, Mapping
    from types import TracebackType

    from install.types import PathLike

_LOGGER = getLogger(__name__)


def apt_install(*packages: str) -> None:
    check_for_commands("apt")
    _LOGGER.info("Updating 'apt'...")
    run_commands("sudo apt -y update")
    desc = ", ".join(map(repr, packages))
    _LOGGER.info("Installing %s...", desc)
    joined = " ".join(packages)
    run_commands(f"sudo apt -y install {joined}")


def brew_install(*packages: str, cask: bool = False) -> None:
    check_for_commands("brew")
    _LOGGER.info("Updating 'brew'...")
    run_commands("brew update")
    desc = ", ".join(map(repr, packages))
    _LOGGER.info("Installing %s...", desc)
    cmd = "brew install"
    if cask:
        cmd = f"{cmd} --cask"
    joined = " ".join(packages)
    run_commands(f"{cmd} {joined}")


def check_for_commands(*cmds: str) -> None:
    missing = [c for c in cmds if not have_command(c)]
    if len(missing) >= 1:
        all_ = ", ".join(map(repr, cmds))
        missing_ = ", ".join(map(repr, missing))
        msg = f"Must have commands {all_}, but {missing_} are missing"
        raise RuntimeError(msg)


def chmod(path: PathLike, /) -> None:
    path = full_path(path)
    mode = path.stat().st_mode
    if mode & S_IXUSR:
        _LOGGER.debug("%r is already executable", str(path))
        return
    _LOGGER.info("Setting %r to be executable...", str(path))
    run_commands(f"sudo chmod u+x {path}")


def cp(path_from: PathLike, path_to: PathLike, /, *, executable: bool = False) -> None:
    path_from, path_to = map(full_path, [path_from, path_to])
    if path_to.exists() and (path_to.read_bytes() == path_from.read_bytes()):
        _LOGGER.debug("%r -> %r already copied", str(path_from), str(path_to))
        return
    rm(path_to)
    _LOGGER.info("Copying %r -> %r...", str(path_from), str(path_to))
    run_commands(f"sudo mkdir -p {path_to.parent}", f"sudo cp {path_from} {path_to}")
    if executable:
        chmod(path_to)


def download(url: str, path: PathLike, /) -> None:
    with urlopen(url) as response, full_path(path).open(mode="wb") as fh:
        _ = fh.write(response.read())


def dpkg_install(path: PathLike, /) -> None:
    check_for_commands("dpkg")
    run_commands(f"sudo dpkg -i {path}")


def full_path(*parts: PathLike) -> Path:
    return Path(*parts).expanduser()


def get_latest_tag(owner: str, repo: str, /) -> str:
    check_for_commands("curl", "jq")
    return get_output(
        f"curl -s https://api.github.com/repos/{owner}/{repo}/releases/latest | jq -r '.tag_name'"
    )


def get_output(cmd: str, /) -> str:
    return check_output(cmd, shell=True, text=True).strip("\n")


def have_command(cmd: str, /) -> bool:
    return which(cmd) is not None


def is_root() -> bool:
    return geteuid() == 0


def luarocks_install(package: str, /) -> None:
    check_for_commands("luarocks")
    run_commands(f"sudo luarocks install {package}")


def replace_line(path: PathLike, from_: str, to: str, /) -> None:
    path = full_path(path)
    lines = path.read_text().splitlines()
    if all(line != from_ for line in lines):
        _LOGGER.debug("%r not found in %r", from_, str(path))
        return
    _LOGGER.info("Replacing %r -> %r in %r", from_, to, str(path))
    run_commands(f"sudo sed -i 's|{from_}|{to}|' {path}")


def replace_lines(path: PathLike, /, *lines: tuple[str, str]) -> None:
    for from_, to in lines:
        replace_line(path, from_, to)


def rm(path: PathLike, /) -> None:
    path = full_path(path)
    if not path.exists():
        _LOGGER.debug("%r is already removed...", str(path))
        return
    _LOGGER.info("Removing %r...", str(path))
    run_commands(f"sudo rm {path}")


def run_commands(*cmds: str, env: Mapping[str, str | None] | None = None) -> None:
    root = is_root()
    with temp_environ(env):
        for cmd in cmds:
            cmd_use = cmd.replace("sudo ", "") if root else cmd
            _ = check_call(cmd_use, shell=True)


def symlink(path_from: PathLike, path_to: PathLike, /) -> None:
    path_from, path_to = map(full_path, [path_from, path_to])
    if path_from.is_symlink() and (path_from.resolve() == path_to.resolve()):
        _LOGGER.debug("%r -> %r already symlinked", str(path_from), str(path_to))
        return
    path_from.parent.mkdir(parents=True, exist_ok=True)
    rm(path_from)
    _LOGGER.info("Symlinking %r -> %r", str(path_from), str(path_to))
    path_from.symlink_to(path_to)


def symlink_if_given(path_from: PathLike, path_to: PathLike | None, /) -> None:
    if path_to is not None:
        symlink(path_from, path_to)


def symlink_many_if_given(*paths: tuple[PathLike, PathLike | None]) -> None:
    for path_from, path_to in paths:
        symlink_if_given(path_from, path_to)


@contextmanager
def temp_environ(env: Mapping[str, str | None] | None = None, /) -> Iterator[None]:
    if env is None:
        yield
        return

    prev = {key: getenv(key) for key in env}

    def apply(mapping: Mapping[str, str | None], /) -> None:
        for key, value in mapping.items():
            if value is None:
                with suppress(KeyError):
                    del environ[key]
            else:
                environ[key] = value

    apply(env)
    try:
        yield
    finally:
        apply(prev)


class TemporaryDirectory:
    def __init__(self) -> None:
        super().__init__()
        self._temp_dir = tempfile.TemporaryDirectory()
        self.path = Path(self._temp_dir.name)

    def __enter__(self) -> Path:
        return Path(self._temp_dir.__enter__())

    def __exit__(
        self,
        exc: type[BaseException] | None,
        val: BaseException | None,
        tb: TracebackType | None,
    ) -> None:
        self._temp_dir.__exit__(exc, val, tb)


def touch(path: PathLike, /) -> None:
    path = full_path(path)
    if path.exists():
        _LOGGER.debug("%r already exists")
        return
    _LOGGER.debug("Touching %r...", str(path))
    run_commands(f"sudo mkdir -p {path}", f"sudo touch {path}")


def update_submodules() -> None:
    _LOGGER.info("Updating submodules...")
    run_commands("git submodule update")


def uv_tool_install(tool: str, /) -> None:
    if have_command(tool):
        _LOGGER.debug("%r is already installed", tool)
        return
    _LOGGER.info("Installing %r...", tool)
    run_commands(f"uv tool install {tool}")


def which(cmd: str, /) -> Path | None:
    result = shutil.which(cmd)
    return None if result is None else full_path(result)


@contextmanager
def yield_download(url: str, /) -> Iterator[Path]:
    filename = full_path(urlparse(url).path).name
    with TemporaryDirectory() as temp_dir:
        temp_file = temp_dir / filename
        download(url, temp_file)
        yield temp_file


@contextmanager
def yield_github_latest_download(
    owner: str, repo: str, filename_template: str, /
) -> Iterator[Path]:
    tag = get_latest_tag(owner, repo)
    filename = Template(filename_template).substitute(tag=tag)
    url = f"https://github.com/{owner}/{repo}/releases/download/{tag}/{filename}"
    with yield_download(url) as temp_file:
        yield temp_file


__all__ = [
    "TemporaryDirectory",
    "apt_install",
    "brew_install",
    "check_for_commands",
    "chmod",
    "cp",
    "download",
    "dpkg_install",
    "full_path",
    "get_latest_tag",
    "get_output",
    "have_command",
    "is_root",
    "luarocks_install",
    "replace_lines",
    "rm",
    "run_commands",
    "symlink",
    "symlink_if_given",
    "symlink_many_if_given",
    "temp_environ",
    "touch",
    "update_submodules",
    "uv_tool_install",
    "which",
    "yield_download",
    "yield_github_latest_download",
]

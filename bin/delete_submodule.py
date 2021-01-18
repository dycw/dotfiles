#!/usr/bin/env python3
from argparse import ArgumentParser
from configparser import ConfigParser
from logging import basicConfig
from logging import DEBUG
from logging import info
from pathlib import Path
from shutil import move
from subprocess import check_output  # noqa:S404
from sys import stdout
from tempfile import TemporaryDirectory


basicConfig(
    format="\033[94m{asctime}\033[0m {msg}",
    datefmt="%Y-%m-%d %H:%M:%S",
    style="{",
    level=DEBUG,
    stream=stdout,
)


def main(name: str) -> None:
    name = name.strip()
    info(f"Attempting to delete submodule {name!r}...")

    # checks
    root = _get_repo_root()
    if not (outer := root.joinpath(name)).exists():
        raise FileNotFoundError(outer)
    if not (inner := root.joinpath(".git", "modules", name)).exists():
        raise FileNotFoundError(inner)
    old_git_config = root.joinpath(".git", "config")
    old_gitmodules = root.joinpath(".gitmodules")
    with TemporaryDirectory() as _temp:
        temp = Path(_temp)
        new_git_config = temp.joinpath("gitconfig")
        _write_config(old_git_config, new_git_config, name)
        new_gitmodules = temp.joinpath("gitsubmodules")
        _write_config(old_gitmodules, new_gitmodules, name)

        # action
        info(f"Ready to delete submodule {name!r}...")
        info(f"Deleting {outer!r}...")
        check_output(["git", "rm", str(outer)])  # noqa:S603,S607

        info(f"Deleting {inner!r}...")
        check_output(["rm", "-rf", str(inner)])  # noqa:S603,S607

        info(f"Removing {name!r} from {old_git_config}...")
        move(new_git_config, old_git_config)

        info(f"Removing {name!r} from {old_gitmodules}...")
        move(new_gitmodules, old_gitmodules)

    info(f"Finished deleting submodule {name!r}")


def _get_repo_root() -> Path:
    (root,) = check_output(  # noqa:S603,S607
        ["git", "rev-parse", "--show-toplevel"], text=True,
    ).splitlines()
    return Path(root)


def _write_config(old_path: Path, new_path: Path, name: str) -> None:
    if not old_path.exists():
        raise FileNotFoundError(old_path)
    parser = ConfigParser()
    parser.read(old_path)
    section = f'submodule "{name}"'
    if not parser.remove_section(section):
        raise KeyError(f'Section "{section}" not found in {old_path}')
    with open(new_path, mode="w") as file:
        parser.write(file)


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("name")
    args = parser.parse_args()
    main(name=args.name)

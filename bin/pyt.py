#!/usr/bin/env python3
from argparse import ArgumentParser
from dataclasses import dataclass
from dataclasses import field
from logging import basicConfig
from logging import DEBUG
from logging import info
from os import environ
from pathlib import Path
from re import search
from subprocess import check_output  # noqa:S404
from subprocess import run  # noqa:S404
from sys import stdout
from typing import Iterator
from typing import List
from typing import Optional


basicConfig(
    format="\033[94m{asctime}\033[0m {msg}",
    datefmt="%Y-%m-%d %H:%M:%S",
    style="{",
    level=DEBUG,
    stream=stdout,
)


@dataclass
class Parsed:
    paths: List[str] = field(default_factory=list)
    k: List[str] = field(default_factory=list)
    m: List[str] = field(default_factory=list)
    n: Optional[int] = None
    flags: List[str] = field(default_factory=list)
    pdb: bool = False


def _parse_extra(*args: str) -> Parsed:
    copy = list(args)
    parsed = Parsed()

    while True:
        try:
            arg = next(arg for arg in copy if search("^(p|pdb)$", arg))
        except StopIteration:
            break
        else:
            copy.remove(arg)
            parsed.pdb = True

    while True:
        try:
            arg = next(arg for arg in copy if search("^-k$", arg))
        except StopIteration:
            break
        else:
            try:
                k_args = copy[copy.index(arg) + 1]
            except IndexError:
                raise RuntimeError(f"No arguments for '-k': {args}")
            copy.remove(arg)
            copy.remove(k_args)
            parsed.k.append(k_args)

    while True:
        try:
            arg = next(arg for arg in copy if search("^-m$", arg))
        except StopIteration:
            break
        else:
            try:
                m_args = copy[copy.index(arg) + 1]
            except IndexError:
                raise RuntimeError(f"No arguments for '-m': {args}")
            copy.remove(arg)
            copy.remove(m_args)
            parsed.m.append(m_args)

    for pattern, caster in [
        (r"^(?:-n)?(\d+)$", lambda x: int(x)),
        ("^(?:-n)?(auto)$", lambda _: 0),
    ]:
        while True:
            try:
                arg, match = next(  # type: ignore
                    (arg, match.group(1))
                    for arg in copy
                    if ((match := search(pattern, arg)) is not None)
                )
            except StopIteration:
                break
            else:
                copy.remove(arg)
                n = caster(match)
                if parsed.n is None:
                    parsed.n = n
                else:
                    raise RuntimeError(
                        f"Multiple arguments for 'n': {parsed.n}, {n}",
                    )

    while True:
        try:
            arg = next(arg for arg in copy if search("^-(-?).+$", arg))
        except StopIteration:
            break
        else:
            copy.remove(arg)
            parsed.flags.append(arg)

    for arg in copy:
        if search(r"^[\w/]+\.py::.+$", arg) or Path(arg).exists():
            parsed.paths.append(arg)
        else:
            parsed.k.append(arg)

    return parsed


def _yield_args(
    *args: str,
    nice: bool = False,
    color: bool = True,
    hypothesis_profile: Optional[str] = None,
    hypothesis_seed: Optional[int] = None,
) -> Iterator[str]:
    if nice:
        yield "nice"
    yield "pytest"
    parsed = _parse_extra(*args)
    for path in parsed.paths:
        yield repr(path)
    for k in parsed.k:
        yield "-k"
        yield k
    for m in parsed.m:
        yield "-m"
        yield m
    if color:
        yield "--color=yes"
    if parsed.pdb and (parsed.n is None):
        yield "--pdb"
    elif parsed.pdb and (parsed.n is not None):
        raise RuntimeError("--pdb is incompatible with -n")
    elif (not parsed.pdb) and (parsed.n is None):
        yield "-f"
    elif (not parsed.pdb) and (parsed.n is not None):
        yield "-f"
        yield f"-n{parsed.n}"
    else:
        raise ValueError(f"Invalid values: {parsed.pdb}, {parsed.n}")
    if hypothesis_profile is not None:
        yield f"--hypothesis-profile={hypothesis_profile}"
    if hypothesis_seed is not None:
        yield f"--hypothesis-seed={hypothesis_seed}"
    yield from parsed.flags


def _get_repo_root() -> Path:
    (root,) = check_output(  # noqa:S603,S607
        ["git", "rev-parse", "--show-toplevel"],
        text=True,
    ).splitlines()
    return Path(root)


def pyt(
    *args: str,
    nice: bool = False,
    color: bool = True,
    hypothesis_profile: Optional[str] = None,
    hypothesis_seed: Optional[int] = None,
    debug: bool = False,
) -> None:
    parts = list(
        _yield_args(
            *args,
            nice=nice,
            color=color,
            hypothesis_profile=hypothesis_profile,
            hypothesis_seed=hypothesis_seed,
        ),
    )
    root = _get_repo_root()
    if debug:
        command = " ".join([f"PYTHONPATH={root}"] + parts)
        info(command)
    else:
        run(  # noqa:S603
            parts,
            env={**environ, **{"PYTHONPATH": str(root)}},
            text=True,
        )


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--nice", action="store_true")
    parser.add_argument("--no-color", action="store_true")
    parser.add_argument("--hyp", default=None, type=str)
    parser.add_argument("--seed", default=None, type=int)
    parser.add_argument("--debug", action="store_true")
    args, extra = parser.parse_known_args()
    pyt(
        *extra,
        nice=args.nice,
        color=not args.no_color,
        hypothesis_profile=args.hyp,
        hypothesis_seed=args.seed,
        debug=args.debug,
    )
    exit()

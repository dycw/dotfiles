#!/usr/bin/env python
from __future__ import annotations

from contextlib import suppress
from dataclasses import dataclass, field
from itertools import chain, permutations, product
from logging import basicConfig, info
from sys import stdout
from typing import TYPE_CHECKING, Literal, override

if TYPE_CHECKING:
    from collections.abc import Iterator


basicConfig(format="{message}", style="{", level="INFO", stream=stdout)


Key = Literal["c", "f", "i", "k", "m", "n", "p", "x"]


class ArgumentError(Exception): ...


@dataclass(frozen=True, kw_only=True)
class Part:
    key: Key
    options: list[str]


@dataclass(frozen=True, kw_only=True)
class Settings:
    f: bool = False
    i: bool = False
    k: bool = False
    n: bool = False
    maxfail: bool = False
    no_cov: bool = False
    pdb: bool = False
    x: bool = False

    def __post_init__(self) -> None:
        if self.f and self.pdb:
            msg = "-f and --pdb are mutually exclusive"
            raise ArgumentError(msg)
        if self.i and self.x:
            msg = "--instafail and -x are mutually exclusive"
            raise ArgumentError(msg)
        if self.i and self.pdb:
            msg = "--instafail and --pdb are mutually exclusive"
            raise ArgumentError(msg)
        if self.k and self.maxfail:
            msg = "-k and --maxfail are mutually exclusive"
            raise ArgumentError(msg)
        if self.maxfail and self.x:
            msg = "--maxfail and -x are mutually exclusive"
            raise ArgumentError(msg)
        if self.n and self.pdb:
            msg = "-n and --pdb are mutually exclusive"
            raise ArgumentError(msg)

    def yield_aliases(self) -> Iterator[Alias]:
        for parts in permutations(self.yield_parts()):
            with suppress(ArgumentError):
                yield Alias(settings=self, parts=list(parts))

    def yield_parts(self) -> Iterator[Part]:
        if self.f:
            yield Part(key="f", options=["-f"])
        if self.i:
            yield Part(key="i", options=["--instafail"])
        if self.k:
            yield Part(key="k", options=["--randomly-dont-reorganize", "-k"])
        if self.maxfail:
            yield Part(key="m", options=["--maxfail"])
        if self.n:
            yield Part(key="n", options=["-nauto"])
        if self.no_cov:
            yield Part(key="c", options=["--no-cov"])
        if self.pdb:
            yield Part(key="p", options=["--pdb"])
        if self.x:
            yield Part(key="x", options=["-x"])


@dataclass(frozen=True, kw_only=True)
class Alias:
    settings: Settings
    parts: list[Part] = field(default_factory=list)

    def __post_init__(self) -> None:
        if self.settings.k and (self.parts[-1].key != "k"):
            msg = "-k must be the last term"
            raise ArgumentError(msg)
        if self.settings.maxfail and (self.parts[-1].key != "m"):
            msg = "--maxfail must be the last term"
            raise ArgumentError(msg)

    @override
    def __repr__(self) -> str:
        keys = "".join(p.key for p in self.parts)
        alias = f"pyt{keys}"
        options = " ".join(
            chain(
                ["-ra", "-svv", "--color=yes", "--strict-markers"],
                *(p.options for p in self.parts),
            )
        )
        command = f"pytest {options}".strip()
        return f"alias {alias}='{command}'"

    @override
    def __str__(self) -> str:
        return repr(self)


def yield_aliases() -> Iterator[Alias]:
    for f, i, k, maxfail, n, no_cov, pdb, x in product(
        [True, False],
        [True, False],
        [True, False],
        [True, False],
        [True, False],
        [True, False],
        [True, False],
        [True, False],
    ):
        try:
            settings = Settings(
                f=f, i=i, k=k, maxfail=maxfail, n=n, no_cov=no_cov, pdb=pdb, x=x
            )
        except ArgumentError:
            pass
        else:
            yield from settings.yield_aliases()


def main() -> None:
    """Echo all the commands, ready for piping to a script."""
    info("#!/usr/bin/env bash")  # noqa: LOG015
    for alias in sorted(yield_aliases(), key=str):
        info(alias)  # noqa: LOG015


if __name__ == "__main__":
    main()

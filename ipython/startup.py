from __future__ import annotations  # noqa: INP001

import datetime as dt
import sys
from abc import ABC, ABCMeta
from collections import Counter, defaultdict, deque
from collections.abc import (
    AsyncGenerator,
    AsyncIterable,
    AsyncIterator,
    Awaitable,
    Callable,
    Collection,
    Container,
    Coroutine,
    Generator,
    Hashable,
    ItemsView,
    Iterable,
    Iterator,
    KeysView,
    Mapping,
    MappingView,
    MutableMapping,
    MutableSequence,
    MutableSet,
    Reversible,
    Sequence,
    Sized,
    ValuesView,
)
from collections.abc import Set as AbstractSet
from contextlib import suppress
from dataclasses import (
    Field,
    asdict,
    astuple,
    dataclass,
    field,
    fields,
    is_dataclass,
    make_dataclass,
    replace,
)
from enum import (
    Enum,
    auto,
)
from pathlib import Path
from subprocess import PIPE, CalledProcessError, check_output

_ = [
    ABC,
    ABCMeta,
    AbstractSet,
    AsyncGenerator,
    dt,
    AsyncIterable,
    AsyncIterator,
    Awaitable,
    Callable,
    CalledProcessError,
    Collection,
    Container,
    Coroutine,
    Counter,
    Field,
    Generator,
    Hashable,
    ItemsView,
    Iterable,
    Iterator,
    KeysView,
    Mapping,
    MappingView,
    MutableMapping,
    MutableSequence,
    MutableSet,
    Enum,
    auto,
    PIPE,
    Path,
    Reversible,
    Sequence,
    Sized,
    ValuesView,
    asdict,
    astuple,
    check_output,
    dataclass,
    defaultdict,
    deque,
    field,
    fields,
    is_dataclass,
    make_dataclass,
    replace,
    suppress,
    sys,
]


# standard library imports

try:
    from collections.abc import Buffer
except ImportError:
    pass
else:
    _ = [Buffer]


# third party imports


try:
    from beartype import beartype  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [beartype]


try:
    from bidict import bidict  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [bidict]


try:
    from bs4 import BeautifulSoup  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [BeautifulSoup]


try:
    from cachetools.func import ttl_cache  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [ttl_cache]


try:
    from cxvpy import (  # type: ignore[]
        Expression,
        Maximize,
        Minimize,
        Problem,
        Variable,
    )
except ModuleNotFoundError:
    pass
else:
    _ = [Expression, Maximize, Minimize, Problem, Variable]


# functions


def _add_src_to_sys_path() -> None:
    try:
        output = check_output(
            ["git", "rev-parse", "--show-toplevel"],  # noqa: S603, S607
            stderr=PIPE,
            text=True,
        )
    except CalledProcessError:
        return
    src = str(Path(output.strip("\n"), "src"))
    if src not in sys.path:
        sys.path.insert(0, src)


_ = _add_src_to_sys_path()

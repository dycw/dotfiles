from __future__ import annotations  # noqa: INP001

import abc
import sys
from abc import ABC, ABCMeta
from collections import (
    Counter,
    defaultdict,
    deque,
)
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
from pathlib import Path
from subprocess import PIPE, CalledProcessError, check_output

_ = [
    Counter,
    AbstractSet,
    defaultdict,
    deque,
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
    abc,
    ABC,
    sys,
    PIPE,
    CalledProcessError,
    check_output,
    ABCMeta,
    suppress,
    Path,
]


# standard library imports

try:
    from collections.abc import Buffer
except ModuleNotFoundError:
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
    from cachetools import ttl_cache  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [ttl_cache]


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

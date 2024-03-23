from __future__ import annotations  # noqa: INP001

import datetime as dt
import gzip
import json
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
from enum import Enum, auto
from functools import cache, cached_property, lru_cache, reduce, wraps
from hashlib import md5
from io import BytesIO, StringIO
from itertools import (
    accumulate,
    chain,
    combinations,
    combinations_with_replacement,
    compress,
    count,
    cycle,
    dropwhile,
    filterfalse,
    groupby,
    islice,
    pairwise,
    permutations,
    product,
    repeat,
    starmap,
    takewhile,
    tee,
    zip_longest,
)
from json import (
    JSONDecoder,
    JSONEncoder,
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
    gzip,
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
    json,
    JSONDecoder,
    JSONEncoder,
    cache,
    cached_property,
    BytesIO,
    StringIO,
    lru_cache,
    reduce,
    wraps,
    Iterable,
    accumulate,
    chain,
    combinations,
    combinations_with_replacement,
    compress,
    count,
    cycle,
    dropwhile,
    filterfalse,
    groupby,
    islice,
    pairwise,
    permutations,
    product,
    repeat,
    starmap,
    takewhile,
    tee,
    zip_longest,
    md5,
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
    import bs4  # type: ignore[]
    from bs4 import BeautifulSoup  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [bs4, BeautifulSoup]


try:
    import cachetools  # type: ignore[]
    from cachetools.func import ttl_cache  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [cachetools, ttl_cache]


try:
    import cxvpy as cvxpy  # type: ignore[]
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
    _ = [cvxpy, Expression, Maximize, Minimize, Problem, Variable]


try:
    from frozendict import frozendict  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [frozendict]


try:
    import humanize  # type: ignore[]
    from humanize import (  # type: ignore[]
        naturaldate,
        naturalday,
        naturaldelta,
        naturalsize,
        naturaltime,
    )
except ModuleNotFoundError:
    pass
else:
    _ = [humanize, naturaldate, naturalday, naturaldelta, naturalsize, naturaltime]


try:
    import hvplot.pandas  # type: ignore[]
except (AttributeError, ModuleNotFoundError):
    pass
else:
    _ = [hvplot.pandas]
try:
    import hvplot.polars  # type: ignore[]
except (AttributeError, ModuleNotFoundError):
    pass
else:
    _ = [hvplot.polars]
try:
    import hvplot.xarray  # type: ignore[]
except (AttributeError, ModuleNotFoundError):
    pass
else:
    _ = [hvplot.xarray]


try:
    import joblib  # type: ignore[]
    from joblib import Memory, Parallel, delayed  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [joblib, Memory, Parallel, delayed]


try:
    from loguru import logger  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [logger]


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

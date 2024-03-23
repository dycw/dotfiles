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
from importlib.util import find_spec
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


if find_spec("numpy") is None:
    from math import (
        ceil,
        exp,
        floor,
        inf,
        isclose,
        isfinite,
        isinf,
        isnan,
        log,
        log2,
        nan,
        sqrt,
    )

    _ = [
        ceil,
        exp,
        floor,
        inf,
        isclose,
        isfinite,
        isinf,
        isnan,
        log,
        log2,
        nan,
        sqrt,
    ]


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


try:
    import luigi  # type: ignore[]
    from luigi import (  # type: ignore[]
        BoolParameter,
        DictParameter,
        EnumParameter,
        ExternalTask,
        FloatParameter,
        IntParameter,
        LocalTarget,
        Task,
        TaskParameter,
        TupleParameter,
        WrapperTask,
        build,
    )
except ModuleNotFoundError:
    pass
else:
    _ = [
        luigi,
        BoolParameter,
        DictParameter,
        EnumParameter,
        ExternalTask,
        FloatParameter,
        IntParameter,
        LocalTarget,
        Task,
        TaskParameter,
        TupleParameter,
        WrapperTask,
        build,
    ]


try:
    import matplotlib as mpl  # type: ignore[]
    import matplotlib.pyplot as plt  # type: ignore[]
    from matplotlib.pyplot import (  # type: ignore[]
        gca,
        gcf,
        subplot,
        twinx,
        twiny,
    )
except ModuleNotFoundError:
    pass
else:
    _ = [
        mpl,
        plt,
        gca,
        gcf,
        subplot,
        twinx,
        twiny,
    ]


try:
    from more_itertools import (  # type: ignore[]
        adjacent,
        all_equal,
        all_unique,
        always_iterable,
        always_reversible,
        batched,
        before_and_after,
        bucket,
        callback_iter,
        chunked,
        chunked_even,
        circular_shifts,
        classify_unique,
        collapse,
        combination_index,
        combination_with_replacement_index,
        consecutive_groups,
        constrained_batches,
        consume,
        consumer,
        convolve,
        count_cycle,
        countable,
        difference,
        distinct_combinations,
        distinct_permutations,
        distribute,
        divide,
        dotproduct,
        duplicates_everseen,
        duplicates_justseen,
        exactly_n,
        factor,
        filter_except,
        filter_map,
        first,
        first_true,
        flatten,
        gray_product,
        groupby_transform,
        grouper,
        ichunked,
        iequals,
        ilen,
        interleave,
        interleave_evenly,
        interleave_longest,
        intersperse,
        is_sorted,
        islice_extended,
        iter_except,
        iter_index,
        iter_suppress,
        iterate,
        last,
        locate,
        longest_common_prefix,
        lstrip,
        make_decorator,
        map_except,
        map_if,
        map_reduce,
        mark_ends,
        matmul,
        minmax,
        ncycles,
        nth,
        nth_combination,
        nth_combination_with_replacement,
        nth_or_last,
        nth_permutation,
        nth_product,
        numeric_range,
        only,
        outer_product,
        pad_none,
        padded,
        padnone,
        partial_product,
        partition,
        partitions,
        permutation_index,
        polynomial_derivative,
        polynomial_eval,
        polynomial_from_roots,
        powerset,
        prepend,
        product_index,
        quantify,
        raise_,
        random_combination,
        random_combination_with_replacement,
        random_permutation,
        random_product,
        repeat_each,
        repeat_last,
        repeatfunc,
        reshape,
        rlocate,
        roundrobin,
        rstrip,
        run_length,
        sample,
        seekable,
        set_partitions,
        side_effect,
        sieve,
        sliced,
        sliding_window,
        sort_together,
        split_after,
        split_at,
        split_before,
        split_into,
        split_when,
        spy,
        stagger,
        strictly_n,
        strip,
        subslices,
        substrings,
        substrings_indexes,
        sum_of_squares,
        tabulate,
        tail,
        takewhile_inclusive,
        time_limited,
        totient,
        triplewise,
        unique_everseen,
        unique_in_window,
        unique_justseen,
        unique_to_each,
        unzip,
        value_chain,
        windowed,
        with_iter,
        zip_broadcast,
        zip_equal,
        zip_offset,
    )
except ModuleNotFoundError:
    pass
else:
    _ = [
        adjacent,
        all_equal,
        all_unique,
        always_iterable,
        always_reversible,
        batched,
        before_and_after,
        bucket,
        callback_iter,
        chunked,
        chunked_even,
        circular_shifts,
        classify_unique,
        collapse,
        combination_index,
        combination_with_replacement_index,
        consecutive_groups,
        constrained_batches,
        consume,
        consumer,
        convolve,
        count_cycle,
        countable,
        difference,
        distinct_combinations,
        distinct_permutations,
        distribute,
        divide,
        dotproduct,
        duplicates_everseen,
        duplicates_justseen,
        exactly_n,
        factor,
        filter_except,
        filter_map,
        first,
        first_true,
        flatten,
        gray_product,
        groupby_transform,
        grouper,
        ichunked,
        iequals,
        ilen,
        interleave,
        interleave_evenly,
        interleave_longest,
        intersperse,
        is_sorted,
        islice_extended,
        iter_except,
        iter_index,
        iter_suppress,
        iterate,
        last,
        locate,
        longest_common_prefix,
        lstrip,
        make_decorator,
        map_except,
        map_if,
        map_reduce,
        mark_ends,
        matmul,
        minmax,
        ncycles,
        nth,
        nth_combination,
        nth_combination_with_replacement,
        nth_or_last,
        nth_permutation,
        nth_product,
        numeric_range,
        only,
        outer_product,
        pad_none,
        padded,
        padnone,
        pairwise,
        partial_product,
        partition,
        partitions,
        permutation_index,
        polynomial_derivative,
        polynomial_eval,
        polynomial_from_roots,
        powerset,
        prepend,
        product_index,
        quantify,
        raise_,
        random_combination,
        random_combination_with_replacement,
        random_permutation,
        random_product,
        repeat_each,
        repeat_last,
        repeatfunc,
        reshape,
        rlocate,
        roundrobin,
        rstrip,
        run_length,
        sample,
        seekable,
        set_partitions,
        side_effect,
        sieve,
        sliced,
        sliding_window,
        sort_together,
        split_after,
        split_at,
        split_before,
        split_into,
        split_when,
        spy,
        stagger,
        strictly_n,
        strip,
        subslices,
        substrings,
        substrings_indexes,
        sum_of_squares,
        tabulate,
        tail,
        takewhile_inclusive,
        time_limited,
        totient,
        triplewise,
        unique_everseen,
        unique_in_window,
        unique_justseen,
        unique_to_each,
        unzip,
        value_chain,
        windowed,
        with_iter,
        zip_broadcast,
        zip_equal,
        zip_offset,
    ]


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

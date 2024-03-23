from __future__ import annotations  # noqa: INP001

import datetime as dt
import gzip
import json
import pickle
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
from json import JSONDecoder, JSONEncoder
from multiprocessing import Pool, cpu_count
from numbers import Integral, Number, Real
from operator import add, and_, attrgetter, itemgetter, mul, or_, sub, truediv
from os import environ, getenv
from pathlib import Path
from platform import system
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
    Integral,
    Number,
    Real,
    Counter,
    Field,
    Generator,
    Pool,
    cpu_count,
    Hashable,
    ItemsView,
    json,
    JSONDecoder,
    JSONEncoder,
    add,
    and_,
    attrgetter,
    itemgetter,
    mul,
    or_,
    sub,
    truediv,
    cache,
    environ,
    getenv,
    cached_property,
    BytesIO,
    StringIO,
    lru_cache,
    pickle,
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
    system,
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

    _ = [ceil, exp, floor, inf, isclose, isfinite, isinf, isnan, log, log2, nan, sqrt]


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
    _ = [gca, gcf, mpl, plt, subplot, twinx, twiny]


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
        zip_offset,
    ]
    if find_spec("tabulate") is None:
        from more_itertools import tabulate  # type: ignore[]

        _ = [tabulate]
    try:
        from utilities.iterables import one, take, transpose  # type: ignore[]
        from utilities.more_itertools import (  # type: ignore[]
            always_iterable,
            peekable,
            windowed_complete,
        )
    except ModuleNotFoundError:
        from more_itertools import (  # type: ignore[]
            always_iterable,
            one,
            peekable,
            take,
            transpose,
            windowed_complete,
        )
    else:
        _ = [always_iterable, one, peekable, take, transpose, windowed_complete]


try:
    import numpy as np  # type: ignore[]
    from numpy import (  # type: ignore[]
        allclose,
        arange,
        array,
        block,
        bool_,
        ceil,
        concatenate,
        corrcoef,
        cumsum,
        diag,
        dtype,
        empty,
        exp,
        exp2,
        expand_dims,
        eye,
        finfo,
        flatnonzero,
        float16,
        float32,
        float64,
        floor,
        histogram,
        hstack,
        iinfo,
        inf,
        int8,
        int16,
        int32,
        int64,
        isclose,
        isfinite,
        isinf,
        isnan,
        issubdtype,
        linspace,
        log,
        log2,
        log10,
        maximum,
        memmap,
        minimum,
        nan,
        nan_to_num,
        nansum,
        ndarray,
        newaxis,
        nonzero,
        ones,
        ones_like,
        ravel,
        set_printoptions,
        sqrt,
        vstack,
        where,
        zeros,
        zeros_like,
    )
    from numpy.linalg import (  # type: ignore[]
        LinAlgError,
        cholesky,
        inv,
    )
    from numpy.random import (  # type: ignore[]
        Generator,
        RandomState,
        default_rng,
    )
    from numpy.typing import (  # type: ignore[]
        NDArray,
    )

except ModuleNotFoundError:
    pass
else:
    _ = [
        Generator,
        LinAlgError,
        NDArray,
        RandomState,
        allclose,
        arange,
        array,
        block,
        bool_,
        ceil,
        cholesky,
        concatenate,
        corrcoef,
        cumsum,
        default_rng,
        diag,
        dtype,
        empty,
        exp,
        exp2,
        expand_dims,
        eye,
        finfo,
        flatnonzero,
        float16,
        float32,
        float64,
        floor,
        histogram,
        hstack,
        iinfo,
        inf,
        int16,
        int32,
        int64,
        int8,
        inv,
        isclose,
        isfinite,
        isinf,
        isnan,
        issubdtype,
        linspace,
        log,
        log10,
        log2,
        maximum,
        memmap,
        minimum,
        nan,
        nan_to_num,
        nansum,
        ndarray,
        newaxis,
        nonzero,
        np,
        ones,
        ones_like,
        ravel,
        set_printoptions,
        sqrt,
        vstack,
        where,
        zeros,
        zeros_like,
    ]


try:
    import pandas as pd  # type: ignore[]
    from pandas import (  # type: ignore[]
        NA,
        BooleanDtype,
        DataFrame,
        DateOffset,
        DatetimeIndex,
        Index,
        Int64Dtype,
        MultiIndex,
        RangeIndex,
        Series,
        StringDtype,
        Timedelta,
        TimedeltaIndex,
        Timestamp,
        bdate_range,
        concat,
        date_range,
        qcut,
        read_csv,
        read_excel,
        read_parquet,
        read_sql,
        read_table,
        set_option,
        to_datetime,
        to_pickle,
    )
    from pandas._libs.missing import (  # type: ignore[]
        NAType,
    )
    from pandas.testing import (  # type: ignore[]
        assert_frame_equal,
        assert_index_equal,
        assert_series_equal,
    )
    from pandas.tseries.offsets import (  # type: ignore[]
        BDay,
        Hour,
        Micro,
        Milli,
        Minute,
        MonthBegin,
        MonthEnd,
        Nano,
        Second,
        Week,
    )
except ModuleNotFoundError:
    pass
else:
    _ = [
        BDay,
        BooleanDtype,
        DataFrame,
        DateOffset,
        DateOffset,
        DatetimeIndex,
        Hour,
        Index,
        Int64Dtype,
        Micro,
        Milli,
        Minute,
        MonthBegin,
        MonthEnd,
        MultiIndex,
        NA,
        NAType,
        Nano,
        RangeIndex,
        Second,
        Series,
        StringDtype,
        Timedelta,
        TimedeltaIndex,
        Timestamp,
        Week,
        assert_frame_equal,
        assert_index_equal,
        assert_series_equal,
        bdate_range,
        concat,
        date_range,
        pd,
        qcut,
        read_csv,
        read_excel,
        read_parquet,
        read_sql,
        read_table,
        set_option,
        to_datetime,
        to_pickle,
    ]
    if find_spec("utilities") is None:
        from pandas import read_pickle  # type: ignore[]

        _ = [read_pickle]

    _min_max_rows = 7
    set_option(
        "display.float_format",
        lambda x: f"{x:,.5f}",
        "display.min_rows",
        _min_max_rows,
        "display.max_rows",
        _min_max_rows,
        "display.max_columns",
        100,
    )


try:
    from tabulate import tabulate  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [tabulate]


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

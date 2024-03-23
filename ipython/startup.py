from __future__ import annotations  # noqa: INP001

import abc
import datetime as dt
import gzip
import hashlib
import itertools as it
import json
import math
import multiprocessing
import numbers
import operator
import os
import pathlib
import pickle
import platform
import pprint
import re
import shutil
import socket
import stat
import string
import subprocess
import sys
from collections import Counter, defaultdict, deque
from collections.abc import (
    Awaitable,
    Callable,
    Collection,
    Container,
    Coroutine,
    Generator,
    Hashable,
    Iterable,
    Iterator,
    Mapping,
    Sequence,
    Sized,
)
from collections.abc import Set as AbstractSet
from contextlib import suppress
from dataclasses import (
    astuple,
    dataclass,
    field,
    fields,
    is_dataclass,
    make_dataclass,
    replace,
)
from enum import Enum, auto
from functools import cached_property, lru_cache, partial, reduce, wraps
from hashlib import md5
from io import BytesIO, StringIO
from itertools import (
    chain,
    dropwhile,
    groupby,
    islice,
    pairwise,
    permutations,
    product,
    repeat,
    starmap,
    takewhile,
)
from json import JSONDecoder, JSONEncoder
from multiprocessing import Pool, cpu_count
from numbers import Integral, Number, Real
from operator import add, and_, attrgetter, itemgetter, mul, or_, sub, truediv
from os import environ, getenv
from pathlib import Path
from platform import system
from random import choice, randint, randrange, shuffle, uniform
from re import DOTALL, escape, findall, fullmatch, match, search
from shutil import copyfile, rmtree, which
from socket import gethostname
from string import ascii_letters, ascii_lowercase, ascii_uppercase
from subprocess import (
    DEVNULL,
    PIPE,
    STDOUT,
    CalledProcessError,
    check_call,
    check_output,
    run,
)
from sys import stderr, stdout

_ = [
    AbstractSet,
    Awaitable,
    BytesIO,
    Callable,
    CalledProcessError,
    wraps,
    Collection,
    Container,
    Coroutine,
    Counter,
    DEVNULL,
    DOTALL,
    Enum,
    Generator,
    Hashable,
    Integral,
    Iterable,
    Iterator,
    JSONDecoder,
    JSONEncoder,
    Mapping,
    Number,
    PIPE,
    PIPE,
    Path,
    Pool,
    Real,
    STDOUT,
    Sequence,
    Sized,
    StringIO,
    abc,
    add,
    and_,
    math,
    ascii_letters,
    ascii_lowercase,
    ascii_uppercase,
    astuple,
    attrgetter,
    auto,
    cached_property,
    chain,
    check_call,
    check_output,
    choice,
    copyfile,
    cpu_count,
    dataclass,
    defaultdict,
    deque,
    dropwhile,
    dt,
    environ,
    escape,
    field,
    fields,
    findall,
    fullmatch,
    getenv,
    gethostname,
    groupby,
    gzip,
    hashlib,
    is_dataclass,
    islice,
    it,
    itemgetter,
    json,
    json,
    lru_cache,
    make_dataclass,
    match,
    md5,
    mul,
    multiprocessing,
    numbers,
    operator,
    or_,
    os,
    pairwise,
    partial,
    pathlib,
    permutations,
    pickle,
    platform,
    pprint,
    pprint,
    product,
    randint,
    randrange,
    re,
    reduce,
    repeat,
    replace,
    rmtree,
    run,
    search,
    shuffle,
    shutil,
    socket,
    socket,
    starmap,
    stat,
    stderr,
    stdout,
    string,
    sub,
    subprocess,
    suppress,
    sys,
    sys,
    system,
    takewhile,
    truediv,
    uniform,
    which,
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
    import cxvpy as cp  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [cp]


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
    from matplotlib.pyplot import gca, gcf, subplot, twinx, twiny  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [gca, gcf, mpl, plt, subplot, twinx, twiny]


try:
    from more_itertools import (  # type: ignore[]
        adjacent,
        all_equal,
        all_unique,
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
    try:
        from tabulate import tabulate  # type: ignore[]
    except ModuleNotFoundError:
        from more_itertools import tabulate  # type: ignore[]
    else:
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
    from numpy.linalg import LinAlgError, cholesky, inv  # type: ignore[]
    from numpy.random import Generator, RandomState, default_rng  # type: ignore[]
    from numpy.typing import NDArray  # type: ignore[]


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
        DateOffset,
        DatetimeIndex,
        Index,
        Int64Dtype,
        MultiIndex,
        RangeIndex,
        StringDtype,
        Timedelta,
        TimedeltaIndex,
        Timestamp,
        bdate_range,
        date_range,
        qcut,
        read_sql,
        read_table,
        set_option,
        to_datetime,
        to_pickle,
    )
    from pandas._libs.missing import NAType  # type: ignore[]
    from pandas.testing import assert_index_equal  # type: ignore[]
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
        StringDtype,
        Timedelta,
        TimedeltaIndex,
        Timestamp,
        Week,
        assert_index_equal,
        bdate_range,
        date_range,
        pd,
        qcut,
        read_sql,
        read_table,
        set_option,
        to_datetime,
        to_pickle,
    ]
    try:
        from utilities.pickle import read_pickle  # type: ignore[]
    except ModuleNotFoundError:
        from pandas import read_pickle  # type: ignore[]
    else:
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
    import polars as pl  # type: ignore[]
    from polars import (  # type: ignore[]
        Array,
        Binary,
        Boolean,
        Categorical,
        Config,
        DataType,
        Date,
        Datetime,
        Decimal,
        Duration,
        Float32,
        Float64,
        Int8,
        Int16,
        Int32,
        Int64,
        List,
        Null,
        Object,
        PolarsDataType,
        Struct,
        Time,
        UInt8,
        UInt16,
        UInt32,
        UInt64,
        Utf8,
        col,
        lit,
        read_avro,
        read_csv_batched,
        read_database,
        read_database_uri,
        read_delta,
        read_ipc,
        read_ipc_schema,
        read_ipc_stream,
        read_json,
        read_ndjson,
        read_ods,
        when,
    )
    from polars.datatypes import DataTypeClass  # type: ignore[]
    from polars.testing import (  # type: ignore[]
        assert_frame_not_equal,
        assert_series_not_equal,
    )
    from polars.type_aliases import SchemaDict  # type: ignore[]

    Config(tbl_rows=7, tbl_cols=100)

except ModuleNotFoundError:
    pass
else:
    _ = [
        Array,
        Binary,
        Boolean,
        Categorical,
        Config,
        DataType,
        DataTypeClass,
        Date,
        Datetime,
        Decimal,
        Duration,
        Float32,
        Float64,
        Int16,
        Int32,
        Int64,
        Int8,
        List,
        Null,
        Object,
        PolarsDataType,
        SchemaDict,
        Struct,
        Time,
        UInt16,
        UInt32,
        UInt64,
        UInt8,
        Utf8,
        assert_frame_not_equal,
        assert_series_not_equal,
        col,
        lit,
        pl,
        read_avro,
        read_csv_batched,
        read_database,
        read_database_uri,
        read_delta,
        read_ipc,
        read_ipc_schema,
        read_ipc_stream,
        read_json,
        read_ndjson,
        read_ods,
        when,
        SchemaDict,
    ]
    try:
        from pandas import (  # type: ignore[]
            DataFrame,
            Series,
            concat,
            read_csv,
            read_excel,
            read_parquet,
        )
        from pandas.testing import (  # type: ignore[]
            assert_frame_equal,
            assert_series_equal,
        )
    except ModuleNotFoundError:
        from polars import (  # type: ignore[]
            DataFrame,
            Series,
            concat,
            read_csv,
            read_excel,
            read_parquet,
        )
        from polars.testing import (  # type: ignore[]
            assert_frame_equal,
            assert_series_equal,
        )
    else:
        _ = [
            DataFrame,
            Series,
            assert_frame_equal,
            assert_series_equal,
            concat,
            read_csv,
            read_excel,
            read_parquet,
        ]


try:
    from pqdm.processes import pqdm  # type: ignore[]m
except ModuleNotFoundError:
    pass
else:
    _ = [pqdm]


try:
    import pydantic  # type: ignore[]
    from pydantic import BaseModel  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [pydantic, BaseModel]


try:
    import requests  # type: ignore[]
    from request import get  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [requests, get]


try:
    import rich  # type: ignore[]
    from rich import inspect, pretty, print  # type: ignore[]
    from rich.traceback import install as _install  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [rich, inspect, pretty, print]

    _install()


try:
    import scipy as sp  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [sp]


try:
    import semver  # type: ignore[]
    from semver import VersionInfo  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [semver, VersionInfo]


try:
    import sqlalchemy as sqla  # type: ignore[]
    import sqlalchemy.orm  # type: ignore[]
    from sqlalchemy import create_engine, select  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [sqla, sqlalchemy.orm, create_engine, select]


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

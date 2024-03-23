from __future__ import annotations  # noqa: INP001

import abc
import csv
import datetime as dt
import enum
import functools
import gzip
import hashlib
import io
import itertools as it
import json
import math
import multiprocessing
import numbers
import operator as op
import os
import pathlib
import pickle
import platform
import pprint
import random
import re
import shutil
import socket
import stat
import string
import subprocess
import sys
import tempfile
import textwrap
import time
import types
import typing
import urllib
import zipfile
from collections import Counter, defaultdict, deque
from collections.abc import (
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
from functools import lru_cache, partial, reduce, wraps
from hashlib import md5
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
from multiprocessing import Pool, cpu_count
from os import environ, getenv
from pathlib import Path
from re import escape, findall, search
from shutil import copyfile, rmtree
from subprocess import PIPE, CalledProcessError, check_call, check_output, run
from tempfile import TemporaryDirectory
from time import sleep
from typing import (
    IO,
    Annotated,
    Any,
    BinaryIO,
    ClassVar,
    Generic,
    Literal,
    NewType,
    NoReturn,
    ParamSpec,
    Protocol,
    TextIO,
    TypeAlias,
    TypeGuard,
    TypeVar,
    Union,
)

_ = [
    tempfile,
    TemporaryDirectory,
    time,
    sleep,
    AbstractSet,
    textwrap,
    Callable,
    CalledProcessError,
    wraps,
    Collection,
    Container,
    Coroutine,
    Counter,
    typing,
    IO,
    Annotated,
    functools,
    Any,
    BinaryIO,
    ClassVar,
    Generic,
    Literal,
    zipfile,
    NewType,
    NoReturn,
    ParamSpec,
    Protocol,
    TextIO,
    TypeAlias,
    TypeGuard,
    TypeVar,
    Union,
    Enum,
    Generator,
    Hashable,
    Iterable,
    Iterator,
    csv,
    enum,
    Mapping,
    Path,
    Pool,
    Sequence,
    Sized,
    abc,
    math,
    astuple,
    auto,
    types,
    typing,
    chain,
    urllib,
    check_call,
    check_output,
    copyfile,
    cpu_count,
    dataclass,
    defaultdict,
    deque,
    dropwhile,
    dt,
    io,
    environ,
    escape,
    field,
    fields,
    findall,
    getenv,
    groupby,
    gzip,
    hashlib,
    random,
    is_dataclass,
    islice,
    it,
    json,
    json,
    lru_cache,
    make_dataclass,
    md5,
    multiprocessing,
    numbers,
    os,
    op,
    pairwise,
    partial,
    pathlib,
    permutations,
    pickle,
    platform,
    pprint,
    pprint,
    product,
    re,
    reduce,
    repeat,
    replace,
    rmtree,
    run,
    search,
    shutil,
    socket,
    socket,
    starmap,
    stat,
    string,
    subprocess,
    suppress,
    sys,
    sys,
    takewhile,
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
except ModuleNotFoundError:
    pass
else:
    _ = [bs4]


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
except ModuleNotFoundError:
    pass
else:
    _ = [humanize]


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
except ModuleNotFoundError:
    pass
else:
    _ = [joblib]


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
    import more_itertools as mi  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [mi]


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
    from pandas import (  # type: ignore[]    from pandas import (
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
except ModuleNotFoundError:
    pass
else:
    _ = [requests]


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
except ModuleNotFoundError:
    pass
else:
    _ = [semver]


try:
    import sqlalchemy as sqla  # type: ignore[]
    import sqlalchemy.orm  # type: ignore[]
    from sqlalchemy import create_engine, select  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [sqla, sqlalchemy.orm, create_engine, select]


try:
    from tabulate import tabulate  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [tabulate]


try:
    import xarray  # type: ignore[]
    from xarray import DataArray, Dataset  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [xarray, DataArray, Dataset]


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

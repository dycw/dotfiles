from __future__ import annotations  # noqa: INP001, RUF100

import abc
import ast
import asyncio
import base64
import bisect
import builtins
import calendar
import cmath
import concurrent.futures
import contextvars
import copy
import csv
import dataclasses
import datetime
import datetime as dt
import decimal
import enum
import fractions
import ftplib
import functools
import gettext
import glob
import gzip
import hashlib
import heapq
import imaplib
import inspect
import io
import itertools
import itertools as it
import json
import locale
import logging
import math
import multiprocessing
import numbers
import operator
import operator as op
import os
import pathlib
import pickle
import platform
import poplib
import pprint
import random
import re
import secrets
import shutil
import smtplib
import socket
import stat
import statistics
import string
import subprocess
import sys
import tempfile
import textwrap
import threading
import time
import types
import typing
import unittest
import urllib
import uuid
import wave
import zipfile
import zoneinfo
from collections import Counter, defaultdict, deque
from collections.abc import (
    AsyncGenerator,
    AsyncIterable,
    AsyncIterator,
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
    asdict,
    astuple,
    dataclass,
    field,
    fields,
    is_dataclass,
    make_dataclass,
    replace,
)
from enum import Enum, IntEnum, auto
from functools import lru_cache, partial, reduce, wraps
from hashlib import md5
from inspect import signature
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
from sys import stdout
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
from zoneinfo import ZoneInfo

_ = [
    AbstractSet,
    Annotated,
    Any,
    AsyncGenerator,
    AsyncIterable,
    AsyncIterator,
    BinaryIO,
    Callable,
    CalledProcessError,
    ClassVar,
    Collection,
    Container,
    Coroutine,
    Counter,
    Enum,
    Generator,
    Generic,
    Hashable,
    IO,
    IntEnum,
    Iterable,
    Iterator,
    Literal,
    Mapping,
    NewType,
    NoReturn,
    ParamSpec,
    Path,
    Pool,
    Protocol,
    Sequence,
    Sized,
    TemporaryDirectory,
    TextIO,
    TypeAlias,
    TypeGuard,
    TypeVar,
    Union,
    ZoneInfo,
    abc,
    asdict,
    ast,
    astuple,
    asyncio,
    auto,
    base64,
    bisect,
    builtins,
    calendar,
    chain,
    check_call,
    check_output,
    cmath,
    concurrent.futures,
    contextvars,
    copy,
    copyfile,
    cpu_count,
    csv,
    dataclass,
    dataclasses,
    datetime,
    decimal,
    defaultdict,
    deque,
    dropwhile,
    dt,
    enum,
    environ,
    escape,
    field,
    fields,
    findall,
    fractions,
    ftplib,
    functools,
    getenv,
    gettext,
    glob,
    groupby,
    gzip,
    hashlib,
    heapq,
    imaplib,
    inspect,
    io,
    is_dataclass,
    islice,
    it,
    itertools,
    json,
    locale,
    logging,
    lru_cache,
    make_dataclass,
    math,
    md5,
    multiprocessing,
    numbers,
    op,
    operator,
    os,
    pairwise,
    partial,
    pathlib,
    permutations,
    pickle,
    platform,
    poplib,
    pprint,
    pprint,
    product,
    random,
    re,
    reduce,
    repeat,
    replace,
    rmtree,
    run,
    search,
    secrets,
    shutil,
    signature,
    sleep,
    smtplib,
    socket,
    socket,
    starmap,
    stat,
    statistics,
    stdout,
    string,
    subprocess,
    suppress,
    sys,
    sys,
    takewhile,
    tempfile,
    textwrap,
    threading,
    time,
    types,
    typing,
    typing,
    unittest,
    urllib,
    uuid,
    wave,
    wraps,
    zipfile,
    zoneinfo,
]


# standard library imports


try:
    from collections.abc import Buffer  # python 3.11
except ImportError:
    pass
else:
    _ = [Buffer]


try:
    from enum import StrEnum  # python 3.11
except ImportError:
    pass
else:
    _ = [StrEnum]


try:
    import tomllib  # python 3.11
except ModuleNotFoundError:
    pass
else:
    _ = [tomllib]


# third party imports


_PANDAS_POLARS_ROWS = 6
_PANDAS_POLARS_COLS = 100


try:
    import altair  # noqa: ICN001
    import altair as alt
    from altair import Chart, condition, datum
except ModuleNotFoundError:
    pass
else:
    _ = [Chart, alt, altair, condition, datum]

    alt.data_transformers.enable("vegafusion")


try:
    from beartype import beartype
except ModuleNotFoundError:
    pass
else:
    _ = [beartype]


try:
    from bidict import bidict
except ModuleNotFoundError:
    pass
else:
    _ = [bidict]


try:
    import bs4
except ModuleNotFoundError:
    pass
else:
    _ = [bs4]


try:
    import cachetools
    from cachetools.func import ttl_cache
except ModuleNotFoundError:
    pass
else:
    _ = [cachetools, ttl_cache]


try:
    import click
except ModuleNotFoundError:
    pass
else:
    _ = [click]


try:
    import cvxpy
    import cxvpy as cp
except ModuleNotFoundError:
    pass
else:
    _ = [cp, cvxpy]


try:
    from frozendict import frozendict
except ModuleNotFoundError:
    pass
else:
    _ = [frozendict]


try:
    import humanize
except ModuleNotFoundError:
    pass
else:
    _ = [humanize]


try:
    import holoviews  # noqa: ICN001
    import holoviews as hv
    from holoviews import extension
except ModuleNotFoundError:
    pass
else:
    HVPLOT_OPTS = {
        "active_tools": ["box_zoom"],
        "default_tools": ["box_zoom", "hover"],
        "show_grid": True,
        "tools": ["pan", "wheel_zoom", "reset", "save", "fullscreen"],
    }

    _ = [extension, holoviews, hv]


try:
    import hvplot.pandas
except (AttributeError, ModuleNotFoundError):
    pass
else:
    _ = [hvplot.pandas]
try:
    import hvplot.polars
except (AttributeError, ModuleNotFoundError):
    pass
else:
    _ = [hvplot.polars]
try:
    import hvplot.xarray
except (AttributeError, ModuleNotFoundError):
    pass
else:
    _ = [hvplot.xarray]


try:
    import hypothesis
except ModuleNotFoundError:
    pass
else:
    _ = [hypothesis]


try:
    import ib_async
    from ib_async import Contract
except ModuleNotFoundError:
    pass
else:
    _ = [Contract, ib_async]


try:
    import joblib
except ModuleNotFoundError:
    pass
else:
    _ = [joblib]


try:
    from loguru import logger
except ModuleNotFoundError:
    pass
else:
    _ = [logger]


try:
    import luigi
    from luigi import (
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
    import matplotlib as mpl
    import matplotlib.pyplot as plt
    from matplotlib.pyplot import gca, gcf, subplot, twinx, twiny
except ModuleNotFoundError:
    pass
else:
    _ = [gca, gcf, mpl, plt, subplot, twinx, twiny]


try:
    import more_itertools
    import more_itertools as mi
    from more_itertools import split_at
except ModuleNotFoundError:
    pass
else:
    _ = [mi, more_itertools, split_at]
    try:
        import utilities
    except ModuleNotFoundError:
        from more_itertools import always_iterable, one, peekable

        _ = [always_iterable, one, peekable]
    else:
        _ = utilities


try:
    import numpy  # noqa: ICN001
    import numpy as np
    from numpy import (
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
    from numpy.linalg import LinAlgError, cholesky, inv
    from numpy.random import Generator, RandomState, default_rng
    from numpy.typing import NDArray
except ModuleNotFoundError:
    from math import inf, nan

    _ = [inf, nan]
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
        numpy,
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
    import pandas  # noqa: ICN001
    import pandas as pd
    from pandas import (
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
        qcut,
        read_pickle,
        read_sql,
        read_table,
        set_option,
        to_datetime,
        to_pickle,
    )
    from pandas._libs.missing import NAType
    from pandas.testing import assert_index_equal
    from pandas.tseries.offsets import (
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
    try:
        from utilities.pickle import read_pickle
    except ModuleNotFoundError:
        pass
    else:
        _ = [read_pickle]

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
        pandas,
        pd,
        qcut,
        read_pickle,
        read_sql,
        read_table,
        set_option,
        to_datetime,
        to_pickle,
    ]

    set_option(
        "display.float_format",
        lambda x: f"{x:,.5f}",
        "display.min_rows",
        _PANDAS_POLARS_ROWS,
        "display.max_rows",
        _PANDAS_POLARS_ROWS,
        "display.max_columns",
        _PANDAS_POLARS_COLS,
    )


try:
    import polars  # noqa: ICN001
    import polars as pl
    from polars import (
        Array,
        Binary,
        Boolean,
        Categorical,
        Config,
        DataFrame,
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
        Series,
        Struct,
        Time,
        UInt8,
        UInt16,
        UInt32,
        UInt64,
        Utf8,
        col,
        concat,
        date_range,
        datetime_range,
        int_range,
        int_ranges,
        lit,
        read_avro,
        read_csv,
        read_csv_batched,
        read_database,
        read_database_uri,
        read_delta,
        read_excel,
        read_json,
        read_ndjson,
        read_ods,
        read_parquet,
        struct,
        when,
    )
    from polars._typing import PolarsDataType, SchemaDict  # type: ignore []
    from polars.datatypes import DataTypeClass
    from polars.testing import (
        assert_frame_equal,
        assert_frame_not_equal,
        assert_series_equal,
        assert_series_not_equal,
    )

    Config(
        tbl_rows=_PANDAS_POLARS_ROWS,
        tbl_cols=_PANDAS_POLARS_COLS,
        thousands_separator=True,
    )
except ModuleNotFoundError:
    try:
        from pandas import (
            DataFrame,
            Series,
            concat,
            date_range,
            read_csv,
            read_excel,
            read_parquet,
        )
        from pandas.testing import assert_frame_equal, assert_series_equal
    except ModuleNotFoundError:
        pass
    else:
        _ = [
            DataFrame,
            Series,
            assert_frame_equal,
            assert_series_equal,
            concat,
            date_range,
            read_csv,
            read_excel,
            read_parquet,
        ]
else:
    _ = [
        Array,
        Binary,
        Boolean,
        Categorical,
        Config,
        DataFrame,
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
        SchemaDict,
        Series,
        Struct,
        Time,
        UInt16,
        UInt32,
        UInt64,
        UInt8,
        Utf8,
        assert_frame_equal,
        assert_frame_not_equal,
        assert_series_equal,
        assert_series_not_equal,
        col,
        concat,
        date_range,
        datetime_range,
        int_range,
        int_ranges,
        lit,
        pl,
        polars,
        read_avro,
        read_csv,
        read_csv_batched,
        read_database,
        read_database_uri,
        read_delta,
        read_excel,
        read_json,
        read_ndjson,
        read_ods,
        read_parquet,
        struct,
        when,
    ]


try:
    from pqdm.processes import pqdm
except ModuleNotFoundError:
    pass
else:
    _ = [pqdm]


try:
    import pydantic
    from pydantic import BaseModel
except ModuleNotFoundError:
    pass
else:
    _ = [pydantic, BaseModel]


try:
    import requests
except ModuleNotFoundError:
    pass
else:
    _ = [requests]


try:
    import rich
    from rich import inspect, pretty, print
    from rich import print as p
    from rich.pretty import pprint, pretty_repr
    from rich.traceback import install as _install
except ModuleNotFoundError:
    pass
else:
    _ = [inspect, p, pprint, pretty, pretty_repr, print, rich]

    _install()


try:
    import scipy
    import scipy as sp
except ModuleNotFoundError:
    pass
else:
    _ = [scipy, sp]


try:
    import semver
except ModuleNotFoundError:
    pass
else:
    _ = [semver]


try:
    import sqlalchemy
    import sqlalchemy as sqla
    import sqlalchemy.orm
    from sqlalchemy import create_engine, func, select
except ModuleNotFoundError:
    pass
else:
    _ = [sqla, sqlalchemy, sqlalchemy.orm, create_engine, select, func]


try:
    import streamlit
    import streamlit as st
except ModuleNotFoundError:
    pass
else:
    _ = [st, streamlit]


try:
    import stringcase
except ModuleNotFoundError:
    pass
else:
    _ = [stringcase]


try:
    from tabulate import tabulate
except ModuleNotFoundError:
    pass
else:
    _ = [tabulate]


try:
    from tqdm import tqdm
except ModuleNotFoundError:
    pass
else:
    _ = [tqdm]


try:
    from utilities.datetime import (
        DAY,
        EPOCH_UTC,
        HOUR,
        MINUTE,
        SECOND,
        WEEK,
        Month,
        date_to_datetime,
        ensure_month,
        get_half_years,
        get_months,
        get_now,
        get_now_hk,
        get_now_tokyo,
        get_quarters,
        get_time_zone_name,
        get_today,
        get_today_hk,
        get_today_tokyo,
        get_years,
        parse_month,
        serialize_month,
    )
    from utilities.functools import partial
    from utilities.git import get_repo_root
    from utilities.iterables import groupby_lists, one
    from utilities.pathlib import list_dir
    from utilities.pickle import read_pickle, write_pickle
    from utilities.re import extract_group, extract_groups
    from utilities.text import ensure_str
    from utilities.types import (
        ensure_class,
        ensure_datetime,
        ensure_float,
        ensure_int,
        ensure_not_none,
        get_class,
        get_class_name,
        make_isinstance,
    )
    from utilities.zoneinfo import HONG_KONG, TOKYO, US_CENTRAL, US_EASTERN, UTC
except ModuleNotFoundError:
    pass
else:
    _ = [
        DAY,
        EPOCH_UTC,
        HONG_KONG,
        HOUR,
        MINUTE,
        Month,
        SECOND,
        TOKYO,
        US_CENTRAL,
        US_EASTERN,
        UTC,
        WEEK,
        date_to_datetime,
        ensure_class,
        ensure_datetime,
        ensure_float,
        ensure_int,
        ensure_month,
        ensure_not_none,
        ensure_str,
        extract_group,
        extract_groups,
        get_class,
        get_class_name,
        get_half_years,
        get_months,
        get_now,
        get_now_hk,
        get_now_tokyo,
        get_quarters,
        get_repo_root,
        get_time_zone_name,
        get_today,
        get_today_hk,
        get_today_tokyo,
        get_years,
        groupby_lists,
        list_dir,
        make_isinstance,
        one,
        parse_month,
        parse_month,
        partial,
        read_pickle,
        serialize_month,
        serialize_month,
        write_pickle,
    ]
    try:
        from utilities.altair import (
            plot_dataframes,
            plot_intraday_dataframe,
            save_chart,
            save_charts_as_pdf,
            vconcat_charts,
        )
    except ModuleNotFoundError:
        pass
    else:
        _ = [
            plot_dataframes,
            plot_intraday_dataframe,
            save_chart,
            save_charts_as_pdf,
            vconcat_charts,
        ]
    try:
        from utilities.atomicwrites import writer
    except ModuleNotFoundError:
        pass
    else:
        _ = [writer]
    try:
        from utilities.more_itertools import (
            always_iterable,
            partition_typeguard,
            peekable,
        )
    except ModuleNotFoundError:
        pass
    else:
        _ = [always_iterable, partition_typeguard, peekable]
    try:
        from utilities.jupyter import show
    except ModuleNotFoundError:
        pass
    else:
        _ = [show]
    try:
        from utilities.pandas import IndexS
    except ModuleNotFoundError:
        pass
    else:
        _ = [IndexS]
    try:
        from utilities.polars import check_polars_dataframe
    except ModuleNotFoundError:
        pass
    else:
        _ = [check_polars_dataframe]
    try:
        from utilities.pytest import throttle
    except ModuleNotFoundError:
        pass
    else:
        _ = [throttle]
    try:
        from utilities.sqlalchemy import get_table, insert_items
    except ModuleNotFoundError:
        pass
    else:
        _ = [get_table, insert_items]
    try:
        from utilities.sqlalchemy_polars import insert_dataframe
    except ModuleNotFoundError:
        pass
    else:
        _ = [insert_dataframe]
    try:
        from utilities.timer import Timer
    except ModuleNotFoundError:
        pass
    else:
        _ = [Timer]
    try:
        from utilities.whenever import (
            ensure_date,
            ensure_local_datetime,
            ensure_time,
            ensure_timedelta,
            ensure_zoned_datetime,
            parse_date,
            parse_local_datetime,
            parse_time,
            parse_timedelta,
            parse_zoned_datetime,
            serialize_date,
            serialize_local_datetime,
            serialize_time,
            serialize_timedelta,
            serialize_zoned_datetime,
        )
    except ModuleNotFoundError:
        pass
    else:
        _ = [
            ensure_date,
            ensure_local_datetime,
            ensure_time,
            ensure_timedelta,
            ensure_zoned_datetime,
            parse_date,
            parse_local_datetime,
            parse_time,
            parse_timedelta,
            parse_zoned_datetime,
            serialize_date,
            serialize_local_datetime,
            serialize_time,
            serialize_timedelta,
            serialize_zoned_datetime,
        ]

try:
    import xarray
    from xarray import DataArray, Dataset
except ModuleNotFoundError:
    pass
else:
    _ = [xarray, DataArray, Dataset]


# functions


def _add_src_to_sys_path() -> None:
    """Add `src/` to `sys.path`."""
    cmd = ["git", "rev-parse", "--show-toplevel"]
    try:
        output = check_output(cmd, stderr=PIPE, text=True)  # noqa: S603
    except CalledProcessError:
        return
    src = str(Path(output.strip("\n"), "src"))
    if src not in sys.path:
        sys.path.insert(0, src)


_ = _add_src_to_sys_path()

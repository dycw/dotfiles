from __future__ import annotations  # noqa: INP001

import abc
import ast
import asyncio
import base64
import bisect
import calendar
import cmath
import concurrent.futures
import contextvars
import copy
import csv
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
from contextlib import ExitStack, suppress
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
from datetime import UTC
from enum import Enum, IntEnum, auto
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
from types import TracebackType
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
    UTC,
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
    io,
    is_dataclass,
    islice,
    it,
    itertools,
    json,
    json,
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
    sleep,
    smtplib,
    socket,
    socket,
    starmap,
    stat,
    statistics,
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


_PANDAS_POLARS_ROWS = 7
_PANDAS_POLARS_COLS = 100


try:
    import altair  # type: ignore[] # noqa: ICN001
    import altair as alt  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [alt, altair]


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
    import click  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [click]


try:
    import cvxpy  # type: ignore[]
    import cxvpy as cp  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [cp, cvxpy]


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
    import holoviews  # type: ignore[] # noqa: ICN001
    import holoviews as hv  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    HVPLOT_OPTS = {
        "active_tools": ["box_zoom"],
        "default_tools": ["box_zoom", "hover"],
        "show_grid": True,
        "tools": ["pan", "wheel_zoom", "reset", "save", "fullscreen"],
    }

    _ = [holoviews, hv]


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
    import hypothesis  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [hypothesis]


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
    import more_itertools  # type: ignore[]
    import more_itertools as mi  # type: ignore[]
    from more_itertools import split_at  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [mi, more_itertools, split_at]


try:
    import numpy  # type: ignore[] # noqa: ICN001
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
    import pandas  # type: ignore[] # noqa: ICN001
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
        read_pickle,
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
    try:
        from utilities.pickle import read_pickle  # type: ignore[]
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
        date_range,
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
    import polars  # type: ignore[] # noqa: ICN001
    import polars as pl  # type: ignore[]
    from polars import (  # type: ignore[]
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
        PolarsDataType,
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
        when,
    )
    from polars.datatypes import DataTypeClass  # type: ignore[]
    from polars.testing import (  # type: ignore[]
        assert_frame_equal,
        assert_frame_not_equal,
        assert_series_equal,
        assert_series_not_equal,
    )
    from polars.type_aliases import SchemaDict  # type: ignore[]

    Config(tbl_rows=_PANDAS_POLARS_ROWS, tbl_cols=_PANDAS_POLARS_COLS)
except ModuleNotFoundError:
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
        pass
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
        when,
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
    import scipy  # type: ignore[]
    import scipy as sp  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [scipy, sp]


try:
    import semver  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [semver]


try:
    import sqlalchemy  # type: ignore[]
    import sqlalchemy as sqla  # type: ignore[]
    import sqlalchemy.orm  # type: ignore[]
    from sqlalchemy import create_engine, func, select  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [sqla, sqlalchemy, sqlalchemy.orm, create_engine, select, func]


try:
    import streamlit  # type: ignore[]
    import streamlit as st  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [st, streamlit]


try:
    from tabulate import tabulate  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [tabulate]


try:
    from utilities.datetime import date_to_datetime, get_now  # type: ignore[]
    from utilities.functools import partial  # type: ignore[]
    from utilities.iterables import one  # type: ignore[]
    from utilities.pandas import IndexS  # type: ignore[]
    from utilities.pathlib import list_dir  # type: ignore[]
    from utilities.polars import check_polars_dataframe  # type: ignore[]
    from utilities.pytest import throttle  # type: ignore[]
    from utilities.re import extract_group, extract_groups  # type: ignore[]
    from utilities.sqlalchemy import get_table, insert_items  # type: ignore[]
    from utilities.sqlalchemy_polars import (  # type: ignore[]
        insert_dataframe,
        select_to_dataframe,
    )
    from utilities.text import ensure_str  # type: ignore[]
    from utilities.types import ensure_not_none  # type: ignore[]
    from utilities.zoneinfo import HONG_KONG  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [
        HONG_KONG,
        IndexS,
        check_polars_dataframe,
        get_now,
        date_to_datetime,
        ensure_not_none,
        ensure_str,
        extract_group,
        extract_groups,
        get_table,
        insert_dataframe,
        insert_items,
        list_dir,
        one,
        partial,
        select_to_dataframe,
        throttle,
    ]

try:
    import xarray  # type: ignore[]
    from xarray import DataArray, Dataset  # type: ignore[]
except ModuleNotFoundError:
    pass
else:
    _ = [xarray, DataArray, Dataset]


# functions


def _add_src_to_sys_path() -> None:
    """Add `src/` to `sys.path`."""
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


@dataclass(kw_only=True)
class _Show:
    """Context manager which adjusts the display of NDFrames."""

    dp: int | None = None
    rows: int | None = _PANDAS_POLARS_ROWS
    columns: int | None = _PANDAS_POLARS_COLS
    stack: ExitStack = field(default_factory=ExitStack)

    def __call__(
        self,
        *,
        dp: int | None = None,
        rows: int | None = _PANDAS_POLARS_ROWS,
        columns: int | None = _PANDAS_POLARS_COLS,
    ) -> _Show:
        return replace(self, dp=dp, rows=rows, columns=columns)

    def __enter__(self) -> None:
        self._enter_pandas()
        self._enter_polars()
        _ = self.stack.__enter__()

    def _enter_pandas(self) -> None:
        try:
            from pandas import option_context  # type: ignore[]
        except ModuleNotFoundError:
            pass
        else:
            kwargs: dict[str, Any] = {}
            if self.dp is not None:
                kwargs["display.precision"] = self.dp
            if self.rows is not None:
                kwargs["display.min_rows"] = kwargs["display.max_rows"] = self.rows
            if self.columns is not None:
                kwargs["display.max_columns"] = self.columns
            if len(kwargs) >= 1:
                context = option_context(*chain(*kwargs.items()))
                self.stack.enter_context(context)

    def _enter_polars(self) -> None:
        try:
            from polars import Config  # type: ignore[]
        except ModuleNotFoundError:
            pass
        else:
            kwargs: dict[str, Any] = {}
            if self.dp is not None:
                kwargs["float_precision"] = self.dp
            if self.rows is not None:
                kwargs["tbl_rows"] = self.rows
            if self.columns is not None:
                kwargs["tbl_cols"] = self.columns
            config = Config(**kwargs)
            _ = self.stack.enter_context(config)

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: TracebackType | None,
    ) -> None:
        _ = self.stack.__exit__(exc_type, exc_val, exc_tb)


show = _Show()

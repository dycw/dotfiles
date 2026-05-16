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
import contextlib
import contextvars
import copy
import csv
import dataclasses
import datetime
import datetime as dt
import decimal
import enum
import fractions
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
import reprlib
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
import zlib
import zoneinfo
from abc import ABC
from abc import ABCMeta
from abc import abstractmethod
from asyncio import CancelledError
from asyncio import Event
from asyncio import Queue
from asyncio import QueueEmpty
from asyncio import QueueFull
from asyncio import TaskGroup
from asyncio import create_task
from asyncio import get_event_loop
from asyncio import get_running_loop
from asyncio import new_event_loop
from asyncio import set_event_loop
from asyncio import sleep as sleep_async
from collections import Counter
from collections import defaultdict
from collections import deque
from collections.abc import AsyncGenerator
from collections.abc import AsyncIterable
from collections.abc import AsyncIterator
from collections.abc import Callable
from collections.abc import Collection
from collections.abc import Container
from collections.abc import Coroutine
from collections.abc import Generator
from collections.abc import Hashable
from collections.abc import Iterable
from collections.abc import Iterator
from collections.abc import Mapping
from collections.abc import Sequence
from collections.abc import Set as AbstractSet
from collections.abc import Sized
from contextlib import AsyncExitStack
from contextlib import ExitStack
from contextlib import asynccontextmanager
from contextlib import contextmanager
from contextlib import redirect_stderr
from contextlib import redirect_stdout
from contextlib import suppress
from dataclasses import InitVar
from dataclasses import asdict
from dataclasses import astuple
from dataclasses import dataclass
from dataclasses import field
from dataclasses import fields
from dataclasses import is_dataclass
from dataclasses import make_dataclass
from dataclasses import replace
from enum import Enum
from enum import IntEnum
from enum import auto
from functools import lru_cache
from functools import partial
from functools import reduce
from functools import wraps
from hashlib import md5
from importlib.util import find_spec
from inspect import isasyncgen
from inspect import isasyncgenfunction
from inspect import iscoroutine
from inspect import iscoroutinefunction
from inspect import isfunction
from inspect import isgenerator
from inspect import isgeneratorfunction
from inspect import signature
from io import StringIO
from itertools import chain
from itertools import count
from itertools import dropwhile
from itertools import groupby
from itertools import islice
from itertools import pairwise
from itertools import permutations
from itertools import product
from itertools import repeat
from itertools import starmap
from itertools import takewhile
from logging import Formatter
from logging import LogRecord
from logging import StreamHandler
from logging import getLogger
from math import inf
from math import log
from math import nan
from multiprocessing import Pool
from multiprocessing import cpu_count
from operator import add
from operator import and_
from operator import attrgetter
from operator import itemgetter
from operator import mul
from operator import neg
from operator import or_
from operator import pos
from operator import sub
from operator import truediv
from os import environ
from os import getenv
from pathlib import Path
from random import shuffle
from re import escape
from re import findall
from re import search
from shlex import join
from shutil import copyfile
from shutil import rmtree
from statistics import fmean
from statistics import mean
from subprocess import PIPE
from subprocess import CalledProcessError
from subprocess import check_call
from subprocess import check_output
from subprocess import run
from sys import exc_info
from sys import stderr
from sys import stdout
from tempfile import TemporaryDirectory
from time import sleep as sleep_sync
from typing import IO
from typing import Annotated
from typing import Any
from typing import BinaryIO
from typing import ClassVar
from typing import Generic
from typing import Literal
from typing import NewType
from typing import NoReturn
from typing import NotRequired
from typing import ParamSpec
from typing import Protocol
from typing import Required
from typing import Self
from typing import TextIO
from typing import TypeAlias
from typing import TypedDict
from typing import TypeGuard
from typing import TypeVar
from typing import overload
from typing import override
from uuid import UUID
from uuid import uuid4
from zlib import crc32
from zoneinfo import ZoneInfo

_LOGGER = getLogger("startup.py")
_LOGGER.addHandler(handler := StreamHandler(stdout))
handler.setFormatter(
    Formatter(fmt="{asctime} | {message}", datefmt="%Y-%m-%d %H:%M:%S", style="{")
)
handler.setLevel("INFO")
_LOGGER.setLevel("INFO")
_ = _LOGGER.info("Running `startup.py`...")


_ = [
    ABC,
    ABCMeta,
    AbstractSet,
    Annotated,
    Any,
    AsyncExitStack,
    AsyncGenerator,
    AsyncIterable,
    AsyncIterator,
    BinaryIO,
    Callable,
    CalledProcessError,
    CancelledError,
    ClassVar,
    Collection,
    Container,
    Coroutine,
    Counter,
    Enum,
    Event,
    ExitStack,
    Formatter,
    Generator,
    Generic,
    Hashable,
    IO,
    InitVar,
    IntEnum,
    Iterable,
    Iterator,
    Literal,
    LogRecord,
    Mapping,
    NewType,
    NoReturn,
    NotRequired,
    ParamSpec,
    Path,
    Pool,
    Protocol,
    Queue,
    QueueEmpty,
    QueueFull,
    Required,
    Self,
    Sequence,
    Sized,
    StreamHandler,
    StringIO,
    TaskGroup,
    TemporaryDirectory,
    TextIO,
    TypeAlias,
    TypeGuard,
    TypeVar,
    TypedDict,
    UUID,
    ZoneInfo,
    abc,
    abstractmethod,
    add,
    and_,
    asdict,
    ast,
    astuple,
    asynccontextmanager,
    asyncio,
    attrgetter,
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
    contextlib,
    contextmanager,
    contextvars,
    copy,
    copyfile,
    count,
    cpu_count,
    crc32,
    create_task,
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
    exc_info,
    field,
    fields,
    findall,
    fmean,
    fractions,
    functools,
    getLogger,
    get_event_loop,
    get_running_loop,
    getenv,
    gettext,
    glob,
    groupby,
    gzip,
    hashlib,
    heapq,
    imaplib,
    inf,
    inspect,
    io,
    is_dataclass,
    isasyncgen,
    isasyncgenfunction,
    iscoroutine,
    iscoroutinefunction,
    isfunction,
    isgenerator,
    isgeneratorfunction,
    islice,
    it,
    itemgetter,
    itertools,
    join,
    json,
    locale,
    log,
    logging,
    lru_cache,
    make_dataclass,
    math,
    md5,
    mean,
    mul,
    multiprocessing,
    nan,
    neg,
    new_event_loop,
    numbers,
    op,
    operator,
    or_,
    os,
    overload,
    override,
    pairwise,
    pairwise,
    partial,
    pathlib,
    permutations,
    pickle,
    platform,
    poplib,
    pos,
    pprint,
    product,
    random,
    re,
    redirect_stderr,
    redirect_stdout,
    reduce,
    repeat,
    replace,
    reprlib,
    rmtree,
    run,
    search,
    secrets,
    set_event_loop,
    shutil,
    signature,
    sleep_async,
    sleep_sync,
    smtplib,
    socket,
    starmap,
    stat,
    statistics,
    stderr,
    stdout,
    string,
    sub,
    subprocess,
    suppress,
    sys,
    sys,
    takewhile,
    tempfile,
    textwrap,
    threading,
    time,
    truediv,
    types,
    typing,
    unittest,
    urllib,
    uuid,
    uuid,
    uuid4,
    wave,
    wraps,
    zipfile,
    zlib,
    zoneinfo,
]


# third party imports


_PANDAS_POLARS_ROWS = 6
_PANDAS_POLARS_COLS = 100


if find_spec("altair") is not None:
    _LOGGER.info("Importing `altair`...")

    import altair  # noqa: ICN001
    import altair as alt
    from altair import Chart
    from altair import condition
    from altair import datum

    _ = [Chart, alt, altair, condition, datum]
    _ = alt.data_transformers.enable("vegafusion")

    if find_spec("utilities") is not None:
        from utilities.altair import plot_dataframes
        from utilities.altair import plot_intraday_dataframe
        from utilities.altair import save_chart
        from utilities.altair import save_charts_as_pdf
        from utilities.altair import vconcat_charts

        _ = [
            plot_dataframes,
            plot_intraday_dataframe,
            save_chart,
            save_charts_as_pdf,
            vconcat_charts,
        ]


if find_spec("atomicwrites") is not None:
    _LOGGER.info("Importing `atomicwrites`...")

    import atomicwrites

    _ = [atomicwrites]


if find_spec("beartype") is not None:
    _LOGGER.info("Importing `beartype`...")

    from beartype import beartype

    _ = [beartype]


if find_spec("bidict") is not None:
    _LOGGER.info("Importing `bidict`...")

    from bidict import bidict

    _ = [bidict]


if find_spec("bs4") is not None:
    _LOGGER.info("Importing `bs4`...")

    import bs4

    _ = [bs4]


if find_spec("cachetools") is not None:
    import cachetools
    from cachetools.func import ttl_cache

    _ = [cachetools, ttl_cache]


if find_spec("click") is not None:
    _LOGGER.info("Importing `click`...")

    import click

    _ = [click]


if find_spec("cvxpy") is not None:
    _LOGGER.info("Importing `cvxpy`...")

    import cvxpy
    import cvxpy as cp

    _ = [cp, cvxpy]


if find_spec("dacite") is not None:
    _LOGGER.info("Importing `dacite`...")

    import dacite
    from dacite import from_dict

    _ = [dacite, from_dict]


if find_spec("eventkit") is not None:
    _LOGGER.info("Importing `eventkit`...")

    import eventkit

    _ = [eventkit]


if find_spec("frozendict") is not None:
    _LOGGER.info("Importing `frozendict`...")

    from frozendict import frozendict

    _ = [frozendict]


if find_spec("humanize") is not None:
    _LOGGER.info("Importing `humanize`...")

    import humanize

    _ = [humanize]


if find_spec("holoviews") is not None:
    _LOGGER.info("Importing `holoviews`...")

    import holoviews  # noqa: ICN001
    import holoviews as hv
    from holoviews import extension

    HVPLOT_OPTS = {
        "active_tools": ["box_zoom"],
        "default_tools": ["box_zoom", "hover"],
        "show_grid": True,
        "tools": ["pan", "wheel_zoom", "reset", "save", "fullscreen"],
    }
    _ = [extension, holoviews, hv]


if find_spec("hvplot") is not None:
    _LOGGER.info("Importing `hvplot`...")

    if find_spec("pandas") is not None:
        import hvplot.pandas

        _ = [hvplot.pandas]
    if find_spec("polars") is not None:
        import hvplot.polars

        _ = [hvplot.polars]
    if find_spec("xarray") is not None:
        import hvplot.xarray

        _ = [hvplot.xarray]

if find_spec("hypothesis") is not None:
    _LOGGER.info("Importing `hypothesis`...")

    import hypothesis

    _ = [hypothesis]


if find_spec("ib_async") is not None:
    _LOGGER.info("Importing `ib_async`...")

    import ib_async
    from ib_async import IB
    from ib_async import BarDataList
    from ib_async import ContFuture
    from ib_async import Contract
    from ib_async import ContractDescription
    from ib_async import ContractDetails
    from ib_async import Forex
    from ib_async import Future
    from ib_async import Order
    from ib_async import OrderStatus
    from ib_async import Position
    from ib_async import RealTimeBar
    from ib_async import RealTimeBarList
    from ib_async import Stock
    from ib_async import Ticker
    from ib_async import Trade
    from ib_async import TradeLogEntry

    _ = [
        BarDataList,
        ContFuture,
        Contract,
        ContractDescription,
        ContractDetails,
        Forex,
        Future,
        IB,
        Order,
        OrderStatus,
        Position,
        RealTimeBar,
        RealTimeBarList,
        Stock,
        Ticker,
        Trade,
        TradeLogEntry,
        ib_async,
    ]


if find_spec("inflect") is not None:
    _LOGGER.info("Importing `inflect`...")

    import inflect

    _ = [inflect]


if find_spec("joblib") is not None:
    _LOGGER.info("Importing `joblib`...")

    import joblib

    _ = [joblib]


if find_spec("lightweight-charts") is not None:
    _LOGGER.info("Importing `lightweight-charts`...")

    import lightweight_charts

    _ = [lightweight_charts]

    if find_spec("utilities") is not None:
        from utilities.lightweight_charts import save_chart
        from utilities.lightweight_charts import yield_chart

        _ = [save_chart, yield_chart]


if find_spec("more-itertools") is not None:
    _LOGGER.info("Importing `more-itertools`...")

    import more_itertools
    import more_itertools as mi
    from more_itertools import always_iterable
    from more_itertools import one
    from more_itertools import partition
    from more_itertools import peekable
    from more_itertools import split_at
    from more_itertools import unique_everseen
    from more_itertools import unique_justseen
    from more_itertools import windowed
    from more_itertools import windowed_complete

    _ = [
        always_iterable,
        mi,
        more_itertools,
        one,
        partition,
        peekable,
        split_at,
        unique_everseen,
        unique_justseen,
        windowed,
        windowed_complete,
    ]

    if find_spec("utilities") is not None:
        from utilities.core import always_iterable
        from utilities.more_itertools import BucketMappingError
        from utilities.more_itertools import Split
        from utilities.more_itertools import bucket_mapping
        from utilities.more_itertools import partition_list
        from utilities.more_itertools import partition_typeguard
        from utilities.more_itertools import peekable
        from utilities.more_itertools import yield_splits

        _ = [
            always_iterable,
            BucketMappingError,
            Split,
            bucket_mapping,
            partition_list,
            partition_typeguard,
            peekable,
            yield_splits,
        ]

if find_spec("numpy") is not None:
    _LOGGER.info("Importing `numpy`...")

    import numpy  # noqa: ICN001
    import numpy as np
    from numpy import allclose
    from numpy import arange
    from numpy import array
    from numpy import block
    from numpy import bool_
    from numpy import ceil
    from numpy import concatenate
    from numpy import corrcoef
    from numpy import cumsum
    from numpy import diag
    from numpy import dtype
    from numpy import empty
    from numpy import exp
    from numpy import exp2
    from numpy import expand_dims
    from numpy import eye
    from numpy import finfo
    from numpy import flatnonzero
    from numpy import float16
    from numpy import float32
    from numpy import float64
    from numpy import floor
    from numpy import histogram
    from numpy import hstack
    from numpy import iinfo
    from numpy import inf  # type: ignore[reportGeneralTypeIssues]
    from numpy import int8
    from numpy import int16
    from numpy import int32
    from numpy import int64
    from numpy import isclose
    from numpy import isfinite
    from numpy import isinf
    from numpy import isnan
    from numpy import issubdtype
    from numpy import linspace
    from numpy import log
    from numpy import log2
    from numpy import log10
    from numpy import maximum
    from numpy import memmap
    from numpy import minimum
    from numpy import nan  # type: ignore[reportGeneralTypeIssues]
    from numpy import nan_to_num
    from numpy import nansum
    from numpy import ndarray
    from numpy import newaxis
    from numpy import nonzero
    from numpy import ones
    from numpy import ones_like
    from numpy import pi
    from numpy import ravel
    from numpy import set_printoptions
    from numpy import sqrt
    from numpy import vstack
    from numpy import where
    from numpy import zeros
    from numpy import zeros_like
    from numpy.linalg import LinAlgError
    from numpy.linalg import cholesky
    from numpy.linalg import inv
    from numpy.random import Generator
    from numpy.random import RandomState
    from numpy.random import default_rng
    from numpy.typing import NDArray

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
        numpy,
        ones,
        ones_like,
        pi,
        ravel,
        set_printoptions,
        sqrt,
        vstack,
        where,
        zeros,
        zeros_like,
    ]


if find_spec("optuna") is not None:
    _LOGGER.info("Importing `optuna`...")
    import optuna
    from optuna import Trial
    from optuna import create_study
    from optuna import create_trial
    from optuna.samplers import RandomSampler

    _ = [RandomSampler, Trial, create_study, create_trial, optuna]

    if find_spec("utilities") is not None:
        from utilities.optuna import get_best_params
        from utilities.optuna import make_objective
        from utilities.optuna import suggest_bool

        _ = [get_best_params, make_objective, suggest_bool]


if find_spec("orjson") is not None:
    _LOGGER.info("Importing `orjson`...")

    import orjson

    _ = [orjson]

    if find_spec("utilities") is not None:
        from utilities.orjson import deserialize
        from utilities.orjson import read_object
        from utilities.orjson import serialize
        from utilities.orjson import write_object

        _ = [deserialize, read_object, serialize, write_object]


if find_spec("pandas") is not None:
    _LOGGER.info("Importing `pandas`...")

    import pandas  # noqa: ICN001
    import pandas as pd
    from pandas import set_option

    _ = [pandas, pd]

    set_option(
        "display.float_format",
        lambda x: f"{x:,.5f}",  # type: ignore[reportUnknownLambdaType]
        "display.min_rows",
        _PANDAS_POLARS_ROWS,
        "display.max_rows",
        _PANDAS_POLARS_ROWS,
        "display.max_columns",
        _PANDAS_POLARS_COLS,
    )


if find_spec("polars") is not None:
    _LOGGER.info("Importing `polars`...")

    import polars  # noqa: ICN001
    import polars as pl
    from polars import Array
    from polars import Binary
    from polars import Boolean
    from polars import Categorical
    from polars import Config
    from polars import DataFrame
    from polars import DataType
    from polars import Datetime
    from polars import Decimal
    from polars import Duration
    from polars import Expr
    from polars import Float32
    from polars import Float64
    from polars import Int8
    from polars import Int16
    from polars import Int32
    from polars import Int64
    from polars import List
    from polars import Null
    from polars import Object
    from polars import Series
    from polars import Struct
    from polars import Time
    from polars import UInt8
    from polars import UInt16
    from polars import UInt32
    from polars import UInt64
    from polars import Utf8
    from polars import all_horizontal
    from polars import any_horizontal
    from polars import coalesce
    from polars import col
    from polars import concat
    from polars import date_range
    from polars import datetime_range
    from polars import from_epoch
    from polars import int_range
    from polars import int_ranges
    from polars import lit
    from polars import max_horizontal
    from polars import mean_horizontal
    from polars import min_horizontal
    from polars import read_avro
    from polars import read_csv
    from polars import read_database
    from polars import read_database_uri
    from polars import read_delta
    from polars import read_excel
    from polars import read_ipc
    from polars import read_json
    from polars import read_ndjson
    from polars import read_ods
    from polars import read_parquet
    from polars import struct
    from polars import sum_horizontal
    from polars import when
    from polars._typing import IntoExprColumn
    from polars._typing import PolarsDataType
    from polars._typing import SchemaDict
    from polars.datatypes import DataTypeClass
    from polars.exceptions import ColumnNotFoundError
    from polars.exceptions import InvalidOperationError
    from polars.exceptions import NoRowsReturnedError
    from polars.selectors import matches
    from polars.testing import assert_frame_equal
    from polars.testing import assert_frame_not_equal
    from polars.testing import assert_series_equal
    from polars.testing import assert_series_not_equal

    _ = Config(
        tbl_rows=_PANDAS_POLARS_ROWS,
        tbl_cols=_PANDAS_POLARS_COLS,
        thousands_separator=True,
    )
    _ = [
        Array,
        Binary,
        Boolean,
        Categorical,
        ColumnNotFoundError,
        Config,
        DataFrame,
        DataType,
        DataTypeClass,
        Datetime,
        Decimal,
        Duration,
        Expr,
        Float32,
        Float64,
        Int16,
        Int32,
        Int64,
        Int8,
        IntoExprColumn,
        InvalidOperationError,
        List,
        NoRowsReturnedError,
        Null,
        Object,
        PolarsDataType,
        SchemaDict,
        Series,
        Struct,
        Time,
        UInt16,
        UInt32,
        UInt64,
        UInt8,
        Utf8,
        all_horizontal,
        any_horizontal,
        assert_frame_equal,
        assert_frame_not_equal,
        assert_series_equal,
        assert_series_not_equal,
        coalesce,
        col,
        concat,
        date_range,
        datetime_range,
        from_epoch,
        int_range,
        int_ranges,
        lit,
        matches,
        max_horizontal,
        mean_horizontal,
        min_horizontal,
        pl,
        polars,
        read_avro,
        read_csv,
        read_database,
        read_database_uri,
        read_delta,
        read_excel,
        read_ipc,
        read_json,
        read_ndjson,
        read_ods,
        read_parquet,
        struct,
        sum_horizontal,
        when,
    ]

    if find_spec("utilities") is not None:
        from utilities.polars import DatetimeHongKong
        from utilities.polars import DatetimeTokyo
        from utilities.polars import DatetimeUSCentral
        from utilities.polars import DatetimeUSEastern
        from utilities.polars import DatetimeUTC
        from utilities.polars import ExprLike
        from utilities.polars import adjust_frequencies
        from utilities.polars import are_frames_equal
        from utilities.polars import boolean_value_counts
        from utilities.polars import check_polars_dataframe
        from utilities.polars import concat_series
        from utilities.polars import convert_time_zone
        from utilities.polars import cross
        from utilities.polars import cross_rolling_quantile
        from utilities.polars import dataclass_to_dataframe
        from utilities.polars import dataclass_to_schema
        from utilities.polars import deserialize_dataframe
        from utilities.polars import deserialize_series
        from utilities.polars import ensure_expr_or_series
        from utilities.polars import get_data_type_or_series_time_zone
        from utilities.polars import insert_after
        from utilities.polars import insert_before
        from utilities.polars import insert_between
        from utilities.polars import is_false
        from utilities.polars import is_near_event
        from utilities.polars import is_true
        from utilities.polars import join
        from utilities.polars import read_dataframe
        from utilities.polars import read_series
        from utilities.polars import replace_time_zone
        from utilities.polars import serialize_dataframe
        from utilities.polars import serialize_series
        from utilities.polars import struct_dtype
        from utilities.polars import to_false
        from utilities.polars import to_not_false
        from utilities.polars import to_not_true
        from utilities.polars import to_true
        from utilities.polars import touch
        from utilities.polars import try_reify_expr
        from utilities.polars import write_dataframe
        from utilities.polars import write_series
        from utilities.polars import zoned_date_time_dtype
        from utilities.polars import zoned_date_time_period_dtype

        _ = [
            DatetimeHongKong,
            DatetimeTokyo,
            DatetimeUSCentral,
            DatetimeUSEastern,
            DatetimeUTC,
            ExprLike,
            adjust_frequencies,
            are_frames_equal,
            boolean_value_counts,
            check_polars_dataframe,
            concat_series,
            convert_time_zone,
            cross,
            cross_rolling_quantile,
            dataclass_to_dataframe,
            dataclass_to_schema,
            deserialize_dataframe,
            deserialize_series,
            ensure_expr_or_series,
            get_data_type_or_series_time_zone,
            insert_after,
            insert_before,
            insert_between,
            is_false,
            is_near_event,
            is_true,
            join,
            read_dataframe,
            read_series,
            replace_time_zone,
            serialize_dataframe,
            serialize_series,
            struct_dtype,
            to_false,
            to_not_false,
            to_not_true,
            to_true,
            touch,
            try_reify_expr,
            write_dataframe,
            write_series,
            zoned_date_time_dtype,
            zoned_date_time_period_dtype,
        ]

        if find_spec("sqlalchemy") is not None:
            from utilities.sqlalchemy_polars import insert_dataframe
            from utilities.sqlalchemy_polars import select_to_dataframe

            _ = [insert_dataframe, select_to_dataframe]

    if find_spec("whenever") is None:
        from polars import Date
    else:
        from whenever import Date
    _ = [Date]


if find_spec("polars-ols") is not None:
    _LOGGER.info("Importing `polars-ols`...")

    import polars_ols

    _ = [polars_ols]

    if find_spec("utilities") is not None:
        from utilities.polars_ols import compute_rolling_ols

        _ = [compute_rolling_ols]


if find_spec("pqdm") is not None:
    _LOGGER.info("Importing `pqdm`...")

    from pqdm.processes import pqdm

    _ = [pqdm]


if find_spec("pydantic") is not None:
    _LOGGER.info("Importing `pydantic`...")

    import pydantic
    from pydantic import BaseModel

    _ = [pydantic, BaseModel]

    if find_spec("utilities") is not None:
        from utilities.pydantic import ensure_secret
        from utilities.pydantic import extract_secret

        _ = [ensure_secret, extract_secret]


if find_spec("pytest") is not None:
    _LOGGER.info("Importing `pytest`...")

    from pytest import fixture
    from pytest import mark
    from pytest import param

    _ = [fixture, mark, param]

    if find_spec("utilities") is not None:
        from utilities.pytest import throttle

        _ = [throttle]


if find_spec("redis") is not None:
    _LOGGER.info("Importing `redis`...")

    import redis
    from redis.asyncio import Redis

    _ = [redis, Redis]

    if find_spec("utilities") is not None:
        from utilities.redis import redis_hash_map_key
        from utilities.redis import redis_key

        _ = [redis_hash_map_key, redis_key]


if find_spec("requests") is not None:
    _LOGGER.info("Importing `requests`...")

    import requests

    _ = [requests]


if find_spec("rich") is not None:
    _LOGGER.info("Importing `rich`...")

    import rich
    from rich import inspect
    from rich import print  # noqa: A004
    from rich import print as p
    from rich.pretty import pprint
    from rich.pretty import pretty_repr

    _ = [inspect, p, pprint, pretty_repr, print, rich]


if find_spec("sklearn") is not None:
    _LOGGER.info("Importing `sklearn`...")

    import sklearn

    _ = [sklearn]


if find_spec("scipy") is not None:
    _LOGGER.info("Importing `scipy`...")

    import scipy
    import scipy as sp

    _ = [scipy, sp]


if find_spec("semver") is not None:
    _LOGGER.info("Importing `semver`...")

    import semver

    _ = [semver]


if find_spec("sqlalchemy") is not None:
    _LOGGER.info("Importing `sqlalchemy`...")

    import sqlalchemy
    import sqlalchemy as sqla
    import sqlalchemy.orm
    from sqlalchemy import Column
    from sqlalchemy import MetaData
    from sqlalchemy import Table
    from sqlalchemy import delete
    from sqlalchemy import func
    from sqlalchemy import select
    from sqlalchemy import tuple_
    from sqlalchemy.engine.url import URL
    from sqlalchemy.orm import selectinload

    _ = [
        Column,
        MetaData,
        Table,
        URL,
        delete,
        func,
        select,
        selectinload,
        sqla,
        sqlalchemy,
        sqlalchemy.orm,
        tuple_,
    ]
    if find_spec("utilities") is not None:
        from utilities.sqlalchemy import create_engine
        from utilities.sqlalchemy import ensure_tables_created
        from utilities.sqlalchemy import ensure_tables_dropped
        from utilities.sqlalchemy import get_table
        from utilities.sqlalchemy import insert_items

        _ = [
            create_engine,
            ensure_tables_created,
            ensure_tables_dropped,
            get_table,
            insert_items,
        ]
        if find_spec("polars") is not None:
            from utilities.sqlalchemy_polars import insert_dataframe
            from utilities.sqlalchemy_polars import select_to_dataframe

            _ = [insert_dataframe, select_to_dataframe]


if find_spec("stringcase") is not None:
    _LOGGER.info("Importing `stringcase`...")

    import stringcase

    _ = [stringcase]


if find_spec("tabulate") is not None:
    _LOGGER.info("Importing `tabulate`...")

    from tabulate import tabulate

    _ = [tabulate]


if find_spec("tenacity") is not None:
    _LOGGER.info("Importing `tenacity`...")

    import tenacity
    from tenacity import retry

    _ = [retry, tenacity]


if find_spec("tqdm") is not None:
    _LOGGER.info("Importing `tqdm`...")

    from tqdm import tqdm

    _ = [tqdm]


if find_spec("tzdata") is not None:
    _LOGGER.info("Importing `tzdata`...")

    import tzdata

    _ = [tzdata]


if find_spec("tzlocal") is not None:
    import tzlocal

    _ = [tzlocal]


if find_spec("utilities") is not None:
    _LOGGER.info("Importing `utilities`...")

    from utilities.asyncio import EnhancedTaskGroup
    from utilities.asyncio import get_items
    from utilities.asyncio import get_items_nowait
    from utilities.asyncio import put_items
    from utilities.asyncio import put_items_nowait
    from utilities.asyncio import sleep_max
    from utilities.asyncio import sleep_rounded
    from utilities.asyncio import sleep_until
    from utilities.constants import DAY
    from utilities.constants import HOUR
    from utilities.constants import LOCAL_TIME_ZONE
    from utilities.constants import LOCAL_TIME_ZONE_NAME
    from utilities.constants import MICROSECOND
    from utilities.constants import MILLISECOND
    from utilities.constants import MINUTE
    from utilities.constants import MONTH
    from utilities.constants import NOW_LOCAL
    from utilities.constants import NOW_UTC
    from utilities.constants import SECOND
    from utilities.constants import SYSTEM_RANDOM
    from utilities.constants import TODAY_LOCAL
    from utilities.constants import TODAY_UTC
    from utilities.constants import UTC
    from utilities.constants import WEEK
    from utilities.constants import YEAR
    from utilities.constants import ZERO_DAYS
    from utilities.constants import ZERO_TIME
    from utilities.constants import HongKong
    from utilities.constants import Sentinel
    from utilities.constants import Tokyo
    from utilities.constants import USCentral
    from utilities.constants import USEastern
    from utilities.constants import sentinel
    from utilities.core import CheckUniqueError
    from utilities.core import OneEmptyError
    from utilities.core import OneError
    from utilities.core import OneNonUniqueError
    from utilities.core import async_sleep
    from utilities.core import check_unique
    from utilities.core import chunked
    from utilities.core import extract_group
    from utilities.core import extract_groups
    from utilities.core import get_class
    from utilities.core import get_class_name
    from utilities.core import get_today_local
    from utilities.core import kebab_case
    from utilities.core import num_days
    from utilities.core import num_hours
    from utilities.core import num_microseconds
    from utilities.core import num_milliseconds
    from utilities.core import num_minutes
    from utilities.core import num_months
    from utilities.core import num_nanoseconds
    from utilities.core import num_seconds
    from utilities.core import num_weeks
    from utilities.core import num_years
    from utilities.core import pascal_case
    from utilities.core import read_pickle
    from utilities.core import set_up_logging
    from utilities.core import snake_case
    from utilities.core import sync_sleep
    from utilities.core import to_date
    from utilities.core import to_logger
    from utilities.core import to_time_zone_name
    from utilities.core import to_zone_info
    from utilities.core import transpose
    from utilities.core import unique_everseen
    from utilities.core import write_pickle
    from utilities.dataclasses import dataclass_to_dict
    from utilities.dataclasses import yield_fields
    from utilities.functions import ensure_class
    from utilities.functions import ensure_float
    from utilities.functions import ensure_int
    from utilities.functions import ensure_not_none
    from utilities.functions import ensure_plain_date_time
    from utilities.functions import ensure_str
    from utilities.functions import ensure_zoned_date_time
    from utilities.functools import partial
    from utilities.iterables import check_iterables_equal
    from utilities.iterables import check_lengths_equal
    from utilities.iterables import check_mappings_equal
    from utilities.iterables import check_sets_equal
    from utilities.iterables import check_subset
    from utilities.iterables import check_superset
    from utilities.iterables import groupby_lists
    from utilities.iterables import one
    from utilities.iterables import one_str
    from utilities.jupyter import show
    from utilities.math import ewm_parameters
    from utilities.math import is_integral
    from utilities.math import safe_round
    from utilities.os import CPU_COUNT
    from utilities.pathlib import ensure_suffix
    from utilities.pathlib import get_repo_root
    from utilities.pathlib import list_dir
    from utilities.pytest import skipif_ci
    from utilities.pytest import throttle_test
    from utilities.random import get_state
    from utilities.random import shuffle
    from utilities.shelve import yield_shelf
    from utilities.subprocess import run
    from utilities.subprocess import set_hostname_cmd
    from utilities.subprocess import ssh
    from utilities.subprocess import ssh_keyscan
    from utilities.subprocess import sudo_cmd
    from utilities.subprocess import tee_cmd
    from utilities.subprocess import uv_run
    from utilities.text import parse_bool
    from utilities.text import parse_none
    from utilities.threading import BackgroundTask
    from utilities.threading import run_in_background
    from utilities.timer import Timer
    from utilities.types import MaybeIterable
    from utilities.types import Number
    from utilities.types import SecretLike
    from utilities.types import StrMapping
    from utilities.types import TimeZone
    from utilities.typing import get_args
    from utilities.typing import get_literal_elements
    from utilities.typing import is_dataclass_class
    from utilities.typing import is_dataclass_instance
    from utilities.typing import is_instance_gen
    from utilities.typing import is_subclass_gen
    from utilities.typing import make_isinstance
    from utilities.whenever import DatePeriod
    from utilities.whenever import ZonedDateTimePeriod
    from utilities.whenever import format_compact
    from utilities.whenever import get_now
    from utilities.whenever import get_now_local
    from utilities.whenever import get_today
    from utilities.whenever import to_date_time_delta
    from utilities.whenever import to_py_date_or_date_time
    from utilities.whenever import to_py_time_delta
    from utilities.whenever import to_time_delta
    from utilities.whenever import to_zoned_date_time

    _ = [
        BackgroundTask,
        CPU_COUNT,
        CheckUniqueError,
        CheckUniqueError,
        DAY,
        DatePeriod,
        EnhancedTaskGroup,
        HOUR,
        HongKong,
        LOCAL_TIME_ZONE,
        LOCAL_TIME_ZONE_NAME,
        MICROSECOND,
        MILLISECOND,
        MINUTE,
        MONTH,
        MaybeIterable,
        NOW_LOCAL,
        NOW_UTC,
        Number,
        OneEmptyError,
        OneEmptyError,
        OneError,
        OneError,
        OneNonUniqueError,
        OneNonUniqueError,
        SECOND,
        SYSTEM_RANDOM,
        SecretLike,
        Sentinel,
        StrMapping,
        TODAY_LOCAL,
        TODAY_UTC,
        TimeZone,
        Timer,
        Tokyo,
        USCentral,
        USEastern,
        UTC,
        WEEK,
        YEAR,
        ZERO_DAYS,
        ZERO_TIME,
        ZonedDateTimePeriod,
        async_sleep,
        check_iterables_equal,
        check_lengths_equal,
        check_mappings_equal,
        check_sets_equal,
        check_subset,
        check_superset,
        check_unique,
        chunked,
        dataclass_to_dict,
        ensure_class,
        ensure_float,
        ensure_int,
        ensure_not_none,
        ensure_plain_date_time,
        ensure_str,
        ensure_suffix,
        ensure_zoned_date_time,
        ewm_parameters,
        extract_group,
        extract_groups,
        format_compact,
        get_args,
        get_class,
        get_class_name,
        get_items,
        get_items_nowait,
        get_literal_elements,
        get_now,
        get_now_local,
        get_repo_root,
        get_state,
        get_today,
        get_today_local,
        groupby_lists,
        is_dataclass_class,
        is_dataclass_instance,
        is_instance_gen,
        is_integral,
        is_subclass_gen,
        kebab_case,
        list_dir,
        make_isinstance,
        num_days,
        num_hours,
        num_microseconds,
        num_milliseconds,
        num_minutes,
        num_months,
        num_nanoseconds,
        num_seconds,
        num_weeks,
        num_years,
        one,
        one_str,
        parse_bool,
        parse_none,
        partial,
        pascal_case,
        put_items,
        put_items_nowait,
        read_pickle,
        run_in_background,
        safe_round,
        sentinel,
        set_hostname_cmd,
        set_up_logging,
        show,
        shuffle,
        skipif_ci,
        sleep_max,
        sleep_rounded,
        sleep_until,
        snake_case,
        ssh,
        ssh_keyscan,
        sudo_cmd,
        sync_sleep,
        tee_cmd,
        throttle_test,
        to_date,
        to_date_time_delta,
        to_logger,
        to_py_date_or_date_time,
        to_py_time_delta,
        to_time_delta,
        to_time_zone_name,
        to_zone_info,
        to_zoned_date_time,
        transpose,
        unique_everseen,
        uv_run,
        write_pickle,
        yield_fields,
        yield_shelf,
    ]


if find_spec("whenever") is not None:
    _LOGGER.info("Importing `whenever`...")

    import whenever
    from whenever import Date
    from whenever import DateDelta
    from whenever import DateTimeDelta
    from whenever import MonthDay
    from whenever import PlainDateTime
    from whenever import Time
    from whenever import TimeDelta
    from whenever import YearMonth
    from whenever import ZonedDateTime

    _ = [
        Date,
        DateDelta,
        DateTimeDelta,
        PlainDateTime,
        MonthDay,
        Time,
        TimeDelta,
        YearMonth,
        ZonedDateTime,
        whenever,
    ]


if find_spec("xarray") is not None:
    _LOGGER.info("Importing `xarray`...")

    import xarray
    from xarray import DataArray
    from xarray import Dataset

    _ = [xarray, DataArray, Dataset]


# functions


def _add_src_to_sys_path() -> None:
    """Add `src/` to `sys.path`."""
    cmd = ["git", "rev-parse", "--show-toplevel"]
    try:
        output = check_output(cmd, stderr=PIPE, text=True)
    except CalledProcessError:
        return
    src = str(Path(output.strip("\n"), "src"))
    if src not in sys.path:
        sys.path.insert(0, src)


_ = _add_src_to_sys_path()


_LOGGER.info("Finished running `startup.py`")

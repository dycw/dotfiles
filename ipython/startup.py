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
from abc import ABC, ABCMeta, abstractmethod
from asyncio import (
    CancelledError,
    Event,
    Queue,
    QueueEmpty,
    QueueFull,
    TaskGroup,
    create_task,
    get_event_loop,
    get_running_loop,
    new_event_loop,
    set_event_loop,
)
from asyncio import sleep as sleep_async
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
from contextlib import (
    AsyncExitStack,
    ExitStack,
    asynccontextmanager,
    contextmanager,
    redirect_stderr,
    redirect_stdout,
    suppress,
)
from dataclasses import (
    InitVar,
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
from importlib.util import find_spec
from inspect import (
    isasyncgen,
    isasyncgenfunction,
    iscoroutine,
    iscoroutinefunction,
    isfunction,
    isgenerator,
    isgeneratorfunction,
    signature,
)
from io import StringIO
from itertools import (
    chain,
    count,
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
from logging import Formatter, LogRecord, StreamHandler, getLogger
from math import inf, log, nan
from multiprocessing import Pool, cpu_count
from operator import add, and_, attrgetter, itemgetter, mul, neg, or_, pos, sub, truediv
from os import environ, getenv
from pathlib import Path
from random import shuffle
from re import escape, findall, search
from shutil import copyfile, rmtree
from statistics import fmean, mean
from subprocess import PIPE, CalledProcessError, check_call, check_output, run
from sys import exc_info, stderr, stdout
from tempfile import TemporaryDirectory
from time import sleep as sleep_sync
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
    NotRequired,
    ParamSpec,
    Protocol,
    Required,
    Self,
    TextIO,
    TypeAlias,
    TypedDict,
    TypeGuard,
    TypeVar,
    Union,
    overload,
    override,
)
from uuid import UUID, uuid4
from zlib import crc32
from zoneinfo import ZoneInfo

_LOGGER = getLogger("startup.py")
_LOGGER.addHandler(handler := StreamHandler(stdout))
handler.setFormatter(
    Formatter(
        fmt="{asctime} | {process} | {name}:{lineno} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
    )
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
    Union,
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
    from altair import Chart, condition, datum

    _ = [Chart, alt, altair, condition, datum]

    alt.data_transformers.enable("vegafusion")

    if find_spec("utilities") is not None:
        from utilities.altair import (
            plot_dataframes,
            plot_intraday_dataframe,
            save_chart,
            save_charts_as_pdf,
            vconcat_charts,
        )

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

    if find_spec("utilities") is not None:
        from utilities.atomicwrites import writer

        _ = [writer]


if find_spec("beartype") is not None:
    _LOGGER.info("Importing `beartype`...")

    from beartype import beartype

    _ = [beartype]


if find_spec("beartype") is not None:
    _LOGGER.info("Importing `beartype`...")

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

    if find_spec("utilities") is not None:
        from utilities.eventkit import add_listener

        _ = [add_listener]

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
    from ib_async import (
        IB,
        BarDataList,
        ContFuture,
        Contract,
        ContractDescription,
        ContractDetails,
        Forex,
        Future,
        Order,
        OrderStatus,
        Position,
        RealTimeBar,
        RealTimeBarList,
        Stock,
        Ticker,
        Trade,
        TradeLogEntry,
    )

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


if find_spec("lightweight_charts") is not None:
    _LOGGER.info("Importing `lightweight_charts`...")

    import lightweight_charts

    _ = [lightweight_charts]

    if find_spec("utilities") is not None:
        from utilities.lightweight_charts import save_chart, yield_chart

        _ = [save_chart, yield_chart]


if find_spec("more_itertools") is not None:
    _LOGGER.info("Importing `more_itertools`...")

    import more_itertools
    import more_itertools as mi
    from more_itertools import (
        always_iterable,
        one,
        partition,
        peekable,
        split_at,
        unique_everseen,
        unique_justseen,
        windowed,
        windowed_complete,
    )

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
        from utilities.more_itertools import (
            BucketMappingError,
            Split,
            bucket_mapping,
            partition_list,
            partition_typeguard,
            peekable,
            yield_splits,
        )

        _ = [
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
        pi,
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
    from optuna import Trial, create_study, create_trial
    from optuna.samplers import RandomSampler

    _ = [RandomSampler, Trial, create_study, create_trial, optuna]

    if find_spec("utilities") is not None:
        from utilities.optuna import get_best_params, make_objective, suggest_bool

        _ = [get_best_params, make_objective, suggest_bool]


if find_spec("orjson") is not None:
    _LOGGER.info("Importing `orjson`...")

    import orjson

    _ = [orjson]

    if find_spec("utilities") is not None:
        from utilities.orjson import deserialize, read_object, serialize, write_object

        _ = [deserialize, read_object, serialize, write_object]


if find_spec("pandas") is not None:
    _LOGGER.info("Importing `pandas`...")

    import pandas  # noqa: ICN001
    import pandas as pd
    from pandas import set_option

    _ = [pandas, pd]

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


if find_spec("polars") is not None:
    _LOGGER.info("Importing `polars`...")

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
        Datetime,
        Decimal,
        Duration,
        Expr,
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
        all_horizontal,
        any_horizontal,
        coalesce,
        col,
        concat,
        date_range,
        datetime_range,
        from_epoch,
        int_range,
        int_ranges,
        lit,
        max_horizontal,
        mean_horizontal,
        min_horizontal,
        read_avro,
        read_csv,
        read_csv_batched,
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
    )
    from polars._typing import (  # type: ignore []
        IntoExprColumn,
        PolarsDataType,
        SchemaDict,
    )
    from polars.datatypes import DataTypeClass
    from polars.exceptions import (
        ColumnNotFoundError,
        InvalidOperationError,
        NoRowsReturnedError,
    )
    from polars.selectors import matches
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
        read_csv_batched,
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
        from utilities.polars import (
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
        )

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
            from utilities.sqlalchemy_polars import (
                insert_dataframe,
                select_to_dataframe,
            )

            _ = [insert_dataframe, select_to_dataframe]

    if find_spec("whenever") is None:
        from polars import Date
    else:
        from whenever import Date
    _ = [Date]

if find_spec("polars_ols") is not None:
    _LOGGER.info("Importing `polars_ols`...")

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


if find_spec("pytest") is not None:
    _LOGGER.info("Importing `pytest`...")

    from pytest import fixture, mark, param  # noqa: PT013

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
        from utilities.redis import redis_hash_map_key, redis_key

        _ = [redis_hash_map_key, redis_key]


if find_spec("requests") is not None:
    _LOGGER.info("Importing `requests`...")

    import requests

    _ = [requests]


if find_spec("rich") is not None:
    _LOGGER.info("Importing `rich`...")

    import rich
    from rich import inspect, print
    from rich import print as p
    from rich.pretty import pprint, pretty_repr

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
    from sqlalchemy import Column, MetaData, Table, delete, func, select, tuple_
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
        from utilities.sqlalchemy import (
            create_engine,
            ensure_tables_created,
            ensure_tables_dropped,
            get_table,
            insert_items,
        )

        _ = [
            create_engine,
            ensure_tables_created,
            ensure_tables_dropped,
            get_table,
            insert_items,
        ]
        if find_spec("polars") is not None:
            from utilities.sqlalchemy_polars import (
                insert_dataframe,
                select_to_dataframe,
            )

            _ = [insert_dataframe, select_to_dataframe]

if find_spec("streamlit") is not None:
    _LOGGER.info("Importing `streamlit`...")

    import streamlit
    import streamlit as st

    _ = [st, streamlit]


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

    if find_spec("utilities") is not None:
        from utilities.tzdata import HongKong, Tokyo, USCentral, USEastern

        _ = [HongKong, Tokyo, USCentral, USEastern]


if find_spec("tzlocal") is not None:
    import tzlocal

    _ = [tzlocal]

    if find_spec("utilities") is not None:
        from utilities.tzlocal import (
            LOCAL_TIME_ZONE,
            LOCAL_TIME_ZONE_NAME,
            get_local_time_zone,
        )

        _ = [LOCAL_TIME_ZONE, LOCAL_TIME_ZONE_NAME, get_local_time_zone]


if find_spec("utilities") is not None:
    _LOGGER.info("Importing `utilities`...")

    from utilities.asyncio import (
        EnhancedTaskGroup,
        sleep_max,
        sleep_rounded,
        sleep_td,
        sleep_until,
    )
    from utilities.dataclasses import dataclass_repr, dataclass_to_dict, yield_fields
    from utilities.enum import ensure_enum
    from utilities.functions import (
        ensure_class,
        ensure_float,
        ensure_int,
        ensure_not_none,
        ensure_plain_date_time,
        ensure_str,
        ensure_zoned_date_time,
        get_class,
        get_class_name,
        make_isinstance,
    )
    from utilities.functools import partial
    from utilities.iterables import (
        OneEmptyError,
        OneError,
        OneNonUniqueError,
        always_iterable,
        check_duplicates,
        check_iterables_equal,
        check_lengths_equal,
        check_mappings_equal,
        check_sets_equal,
        check_subset,
        check_superset,
        chunked,
        groupby_lists,
        one,
        one_maybe,
        one_str,
        one_unique,
        transpose,
        unique_everseen,
    )
    from utilities.jupyter import show
    from utilities.logging import (
        SizeAndTimeRotatingFileHandler,
        basic_config,
        setup_logging,
    )
    from utilities.math import ewm_parameters, is_integral, safe_round
    from utilities.os import CPU_COUNT
    from utilities.pathlib import (
        ensure_suffix,
        get_package_root,
        get_repo_root,
        get_root,
        list_dir,
    )
    from utilities.pickle import read_pickle, write_pickle
    from utilities.random import SYSTEM_RANDOM, get_state, shuffle
    from utilities.re import extract_group, extract_groups
    from utilities.shelve import yield_shelf
    from utilities.text import parse_bool, parse_none
    from utilities.threading import BackgroundTask, run_in_background
    from utilities.timer import Timer
    from utilities.types import MaybeIterable, Number, StrMapping, TimeZone
    from utilities.typing import get_args, get_literal_elements
    from utilities.whenever import (
        DAY,
        HOUR,
        MICROSECOND,
        MILLISECOND,
        MINUTE,
        MONTH,
        NOW_LOCAL,
        NOW_UTC,
        SECOND,
        TODAY_LOCAL,
        TODAY_UTC,
        WEEK,
        YEAR,
        ZERO_DAYS,
        ZERO_TIME,
        DatePeriod,
        ZonedDateTimePeriod,
        format_compact,
        get_now,
        get_now_local,
        get_today,
        get_today_local,
        to_date,
        to_date_time_delta,
        to_days,
        to_hours,
        to_local_plain,
        to_microseconds,
        to_milliseconds,
        to_minutes,
        to_months,
        to_months_and_days,
        to_nanoseconds,
        to_py_date_or_date_time,
        to_py_time_delta,
        to_seconds,
        to_time_delta,
        to_weeks,
        to_years,
        to_zoned_date_time,
    )
    from utilities.zoneinfo import UTC, ensure_time_zone, get_time_zone_name

    _ = [
        BackgroundTask,
        CPU_COUNT,
        DAY,
        DatePeriod,
        EnhancedTaskGroup,
        HOUR,
        MICROSECOND,
        MILLISECOND,
        MINUTE,
        MONTH,
        MaybeIterable,
        NOW_LOCAL,
        NOW_UTC,
        Number,
        OneEmptyError,
        OneError,
        OneNonUniqueError,
        SECOND,
        SYSTEM_RANDOM,
        SizeAndTimeRotatingFileHandler,
        StrMapping,
        TODAY_LOCAL,
        TODAY_UTC,
        TimeZone,
        Timer,
        UTC,
        WEEK,
        YEAR,
        ZERO_DAYS,
        ZERO_TIME,
        ZonedDateTimePeriod,
        always_iterable,
        basic_config,
        check_duplicates,
        check_iterables_equal,
        check_lengths_equal,
        check_mappings_equal,
        check_sets_equal,
        check_subset,
        check_superset,
        chunked,
        dataclass_repr,
        dataclass_to_dict,
        ensure_class,
        ensure_enum,
        ensure_float,
        ensure_int,
        ensure_not_none,
        ensure_plain_date_time,
        ensure_str,
        ensure_suffix,
        ensure_time_zone,
        ensure_zoned_date_time,
        ewm_parameters,
        extract_group,
        extract_groups,
        format_compact,
        get_args,
        get_class,
        get_class_name,
        get_literal_elements,
        get_now,
        get_now_local,
        get_package_root,
        get_repo_root,
        get_root,
        get_state,
        get_time_zone_name,
        get_today,
        get_today_local,
        groupby_lists,
        is_integral,
        list_dir,
        make_isinstance,
        one,
        one_maybe,
        one_str,
        one_unique,
        parse_bool,
        parse_none,
        partial,
        read_pickle,
        run_in_background,
        safe_round,
        setup_logging,
        show,
        shuffle,
        sleep_max,
        sleep_rounded,
        sleep_td,
        sleep_until,
        to_date,
        to_date_time_delta,
        to_days,
        to_hours,
        to_local_plain,
        to_microseconds,
        to_milliseconds,
        to_minutes,
        to_months,
        to_months_and_days,
        to_nanoseconds,
        to_py_date_or_date_time,
        to_py_time_delta,
        to_seconds,
        to_time_delta,
        to_weeks,
        to_years,
        to_zoned_date_time,
        transpose,
        unique_everseen,
        write_pickle,
        yield_fields,
        yield_shelf,
    ]


if find_spec("xarray") is not None:
    _LOGGER.info("Importing `xarray`...")

    import xarray
    from xarray import DataArray, Dataset

    _ = [xarray, DataArray, Dataset]


if find_spec("whenever") is not None:
    _LOGGER.info("Importing `whenever`...")

    import whenever
    from whenever import (
        Date,
        DateDelta,
        DateTimeDelta,
        LocalDateTime,
        MonthDay,
        Time,
        TimeDelta,
        YearMonth,
        ZonedDateTime,
    )

    _ = [
        Date,
        DateDelta,
        DateTimeDelta,
        LocalDateTime,
        MonthDay,
        Time,
        TimeDelta,
        YearMonth,
        ZonedDateTime,
        whenever,
    ]


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


_LOGGER.info("Finished running `startup.py`")

local ls = require("luasnip")
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("python", {
    -- abc
    s("ab-abc", { t({ "from abc import ABC", "" }) }),
    s("ab-abstract-method", { t({ "from abc import abstractmethod", "" }) }),

    -- asyncio
    s("im-asyncio", { t({ "import asyncio", "" }) }),
    s("as-create-task", { t({ "from asyncio import create_task", "" }) }),
    s("as-event", { t({ "from asyncio import Event", "" }) }),
    s("as-get-event-loop", { t({ "from asyncio import get_event_loop", "" }) }),
    s("as-lock", { t({ "from asyncio import Lock", "" }) }),
    s("as-queue", { t({ "from asyncio import Queue", "" }) }),
    s("as-run", { t({ "from asyncio import run", "" }) }),
    s("as-sleep", { t({ "from asyncio import sleep", "" }) }),
    s("as-task", { t({ "from asyncio import Task", "" }) }),
    s("as-task-group", { t({ "from asyncio import TaskGroup", "" }) }),

    -- beartype
    s("be-beartype", { t({ "from beartype import beartype", "" }) }),

    -- bidict
    s("bi-bidict", { t({ "from bidict import bidict", "" }) }),

    -- breakpoints
    s("bp", { t({ "breakpoint()", "" }) }),
    s("gb", {
        t({ "from utilities.contextvars import global_breakpoint", "" }),
        t({ "global_breakpoint()", "" }),
    }),
    s("rnie", { t({ "raise NotImplementedError", "" }) }),
    s("sgb", {
        t({ "from utilities.contextvars import set_global_breakpoint", "" }),
        t({ "set_global_breakpoint()", "" }),
    }),

    -- cachetools
    s("ca-ttl-cache", { t({ "from cachetools.func import ttl_cache", "" }) }),

    -- click
    s("cl-argument", { t({ "from click import argument", "" }) }),
    s("cl-cli-runner", { t({ "from click.testing import CliRunner", "" }) }),
    s("cl-command", { t({ "from click import command", "" }) }),
    s("cl-option", { t({ "from click import option", "" }) }),

    -- collections
    s("co-abstract-set", { t({ "from collections.abc import Set as AbstractSet", "" }) }),
    s("co-awaitable", { t({ "from collections.abc import Awaitable", "" }) }),
    s("co-callable", { t({ "from collections.abc import Callable", "" }) }),
    s("co-counter", { t({ "from collections import Counter", "" }) }),
    s("co-deque", { t({ "from collections import deque", "" }) }),
    s("co-iterable", { t({ "from collections.abc import Iterable", "" }) }),
    s("co-iterator", { t({ "from collections.abc import Iterator", "" }) }),
    s("co-mapping", { t({ "from collections.abc import Mapping", "" }) }),
    s("co-sequence", { t({ "from collections.abc import Sequence", "" }) }),

    -- contextlib
    s("co-async-exit-stack", { t({ "from contextlib import AsyncExitStack", "" }) }),
    s("co-asynccontextmanager", { t({ "from contextlib import asynccontextmanager", "" }) }),
    s("co-contextmanager", { t({ "from contextlib import contextmanager", "" }) }),
    s("co-exit-stack", { t({ "from contextlib import ExitStack", "" }) }),
    s("co-redirect-stderr", { t({ "from contextlib import redirect_stderr", "" }) }),
    s("co-redirect-stdout", { t({ "from contextlib import redirect_stdout", "" }) }),
    s("co-suppress", { t({ "from contextlib import suppress", "" }) }),

    -- dataclasses
    s("da-asdict", { t({ "from dataclasses import asdict", "" }) }),
    s("da-astuple", { t({ "from dataclasses import astuple", "" }) }),
    s("da-dataclass", { t({ "from dataclasses import dataclass", "" }) }),
    s("da-dataclass-kw", { t({ "@dataclass(kw_only=True)", "" }) }),
    s("da-field", { t({ "from dataclasses import field", "" }) }),
    s("da-init-var", { t({ "from dataclasses import InitVar", "" }) }),
    s("da-replace", { t({ "from dataclasses import replace", "" }) }),
    s("dataclass-or-un-kw", {
        t({ "@dataclass(order=True, unsafe_hash=True, kw_only=True)", "" }),
        t({ "class " }),
        i(1, "ClassName"),
        t({ ":", "" }),
        t("    "),
        i(2, "field1"),
        t(": "),
        i(3, "annotation1"),
        t({ "", "" }),
    }),
    s("dataclass-or-un-kw-sl", {
        t({ "@dataclass(order=True, unsafe_hash=True, kw_only=True, slots=True)", "" }),
        t({ "class " }),
        i(1, "ClassName"),
        t({ ":", "" }),
        t("    "),
        i(2, "field1"),
        t(": "),
        i(3, "annotation1"),
        t({ "", "" }),
    }),
    s("dataclass-kw", {
        t({ "@dataclass(kw_only=True)", "" }),
        t({ "class " }),
        i(1, "ClassName"),
        t({ ":", "" }),
        t("    "),
        i(2, "field1"),
        t(": "),
        i(3, "annotation1"),
        t({ "", "" }),
    }),
    s("dataclass-kw-sl", {
        t({ "@dataclass(kw_only=True, slots=True)", "" }),
        t({ "class " }),
        i(1, "ClassName"),
        t({ ":", "" }),
        t("    "),
        i(2, "field1"),
        t(": "),
        i(3, "annotation1"),
        t({ "", "" }),
    }),

    -- datetime
    s("im-dt", { t({ "import datetime as dt", "" }) }),

    -- enum
    s("im-enum", { t({ "import enum", "" }) }),
    s("en-auto", { t({ "from enum import auto", "" }) }),
    s("en-enum", { t({ "from enum import Enum", "" }) }),
    s("en-str-enum", { t({ "from enum import StrEnum", "" }) }),
    s("en-unique", { t({ "from enum import unique", "" }) }),

    -- errors
    s("no-t201", { t({ "# noqa: T201", "" }) }),
    s("ex-n801", { t({ "(Exception): ...  # noqa: N801", "" }) }),

    -- frozendict
    s("fr-frozendict", { t({ "from frozendict import frozendict", "" }) }),

    -- functools
    s("fu-cached-property", { t({ "from functools import cached_property", "" }) }),
    s("fu-partial", { t({ "from functools import partial", "" }) }),
    s("fu-reduce", { t({ "from functools import reduce", "" }) }),
    s("fu-total-ordering", { t({ "from functools import total_ordering", "" }) }),
    s("fu-wraps", { t({ "from functools import wraps", "" }) }),

    -- future
    s("fu-annotations", { t({ "from __future__ import annotations", "" }) }),

    -- getpass
    s("ge-getuser", { t({ "from getpass import getuser", "" }) }),

    -- humanize
    s("hu-naturaldelta", { t({ "from humanize import naturaldelta", "" }) }),
    s("hu-naturaltime", { t({ "from humanize import naturaltime", "" }) }),

    -- hypothesis
    s("da-data-object", { t({ "data: DataObject" }) }),
    s("hy-assume", { t({ "from hypothesis import assume", "" }) }),
    s("hy-binary", { t({ "from hypothesis.strategies import binary", "" }) }),
    s("hy-booleans", { t({ "from hypothesis.strategies import booleans", "" }) }),
    s("hy-builds", { t({ "from hypothesis.strategies import builds", "" }) }),
    s("hy-composite", { t({ "from hypothesis.strategies import composite", "" }) }),
    s("hy-data", { t({ "from hypothesis.strategies import data, DataObject", "" }) }),
    s("hy-dates", { t({ "from hypothesis.strategies import dates", "" }) }),
    s("hy-datetimes", { t({ "from hypothesis.strategies import datetimes", "" }) }),
    s("hy-draw-fn", { t({ "from hypothesis.strategies import DrawFn", "" }) }),
    s("hy-floats", { t({ "from hypothesis.strategies import floats", "" }) }),
    s("hy-given", { t({ "from hypothesis import given", "" }) }),
    s("hy-health-check", { t({ "from hypothesis import HealthCheck", "" }) }),
    s("hy-integers", { t({ "from hypothesis.strategies import integers", "" }) }),
    s("hy-invalid-argument", { t({ "from hypothesis.errors import InvalidArgument", "" }) }),
    s("hy-just", { t({ "from hypothesis.strategies import just", "" }) }),
    s("hy-lists", { t({ "from hypothesis.strategies import lists", "" }) }),
    s("hy-none", { t({ "from hypothesis.strategies import none", "" }) }),
    s("hy-permutations", { t({ "from hypothesis.strategies import permutations", "" }) }),
    s("hy-phase", { t({ "from hypothesis import Phase", "" }) }),
    s("hy-randoms", { t({ "from hypothesis.strategies import randoms", "" }) }),
    s("hy-reproduce-failure", { t({ "from hypothesis import reproduce_failure", "" }) }),
    s("hy-sampled-from", { t({ "from hypothesis.strategies import sampled_from", "" }) }),
    s("hy-sets", { t({ "from hypothesis.strategies import sets", "" }) }),
    s("hy-settings", { t({ "from hypothesis import settings", "" }) }),
    s("hy-tuples", { t({ "from hypothesis.strategies import tuples", "" }) }),
    s("settings-filter-too-much", { t({ "@settings(suppress_health_check={HealthCheck.filter_too_much})", "" }) }),
    s(
        "settings-function-scoped-fixture",
        { t({ "@settings(suppress_health_check={HealthCheck.function_scoped_fixture})", "" }) }
    ),
    s("settings-generate-only", { t({ "@settings(phases={Phase.generate})", "" }) }),
    s("settings-max-examples", { t({ "@settings(max_examples=1)", "" }) }),

    -- ib-async
    s("ib-commission-report", { t({ "from ib_async import CommissionReport", "" }) }),
    s("ib-cont-future", { t({ "from ib_async import ContFuture", "" }) }),
    s("ib-contract", { t({ "from ib_async import Contract", "" }) }),
    s("ib-contract-details", { t({ "from ib_async import ContractDetails", "" }) }),
    s("ib-crypto", { t({ "from ib_async import Crypto", "" }) }),
    s("ib-execution", { t({ "from ib_async import Execution", "" }) }),
    s("ib-fill", { t({ "from ib_async import Fill", "" }) }),
    s("ib-forex", { t({ "from ib_async import Forex", "" }) }),
    s("ib-future", { t({ "from ib_async import Future", "" }) }),
    s("ib-ib", { t({ "from ib_async import IB", "" }) }),
    s("ib-index", { t({ "from ib_async import Index", "" }) }),
    s("ib-order", { t({ "from ib_async import Order", "" }) }),
    s("ib-order-status", { t({ "from ib_async import OrderStatus", "" }) }),
    s("ib-stock", { t({ "from ib_async import Stock", "" }) }),
    s("ib-trade", { t({ "from ib_async import Trade", "" }) }),

    -- inspect
    s("in-signature", { t({ "from inspect import signature", "" }) }),

    -- io
    s("io-string-io", { t({ "from io import StringIO", "" }) }),

    -- itertools
    s("it-accumulate", { t({ "from itertools import accumulate", "" }) }),
    s("it-chain", { t({ "from itertools import chain", "" }) }),
    s("it-count", { t({ "from itertools import count", "" }) }),
    s("it-cycle", { t({ "from itertools import cycle", "" }) }),
    s("it-dropwhile", { t({ "from itertools import dropwhile", "" }) }),
    s("it-groupby", { t({ "from itertools import groupby", "" }) }),
    s("it-islice", { t({ "from itertools import islice", "" }) }),
    s("it-pairwise", { t({ "from itertools import pairwise", "" }) }),
    s("it-product", { t({ "from itertools import product", "" }) }),
    s("it-repeat", { t({ "from itertools import repeat", "" }) }),
    s("it-starmap", { t({ "from itertools import starmap", "" }) }),
    s("it-takewhile", { t({ "from itertools import takewhile", "" }) }),

    -- logging
    s("logger-name", { t({ "from utilities.logging import to_logger", "", "_LOGGER = to_logger(__name__)", "" }) }),
    s("lo-formatter", { t({ "from logging import Formatter", "" }) }),
    s("lo-get-logger", { t({ "from logging import getLogger", "" }) }),
    s("lo-handler", { t({ "from logging import Handler", "" }) }),
    s("lo-stream-handler", { t({ "from logging import StreamHandler", "" }) }),

    -- math
    s("ma-inf", { t({ "from math import inf", "" }) }),
    s("ma-isclose", { t({ "from math import isclose", "" }) }),
    s("ma-isnan", { t({ "from math import isnan", "" }) }),
    s("ma-nan", { t({ "from math import nan", "" }) }),

    -- more-itertools
    s("mi-chunked", { t({ "from more_itertools import chunked", "" }) }),
    s("mi-iterate", { t({ "from more_itertools import iterate", "" }) }),
    s("mi-partition", { t({ "from more_itertools import partition", "" }) }),
    s("mi-split-at", { t({ "from more_itertools import split_after", "" }) }),

    -- numpy
    s("im-np", { t({ "import numpy as np", "" }) }),
    s("np-arange", { t({ "from numpy import arange", "" }) }),
    s("np-full", { t({ "from numpy import full", "" }) }),
    s("np-isnan", { t({ "from numpy import isnan", "" }) }),
    s("np-linspace", { t({ "from numpy import linspace", "" }) }),
    s("np-nan", { t({ "from numpy import nan", "" }) }),
    s("np-ndarray", { t({ "from numpy import ndarray", "" }) }),
    s("np-pi", { t({ "from numpy import pi", "" }) }),

    -- operator
    s("op-add", { t({ "from operator import add", "" }) }),
    s("op-and", { t({ "from operator import and_", "" }) }),
    s("op-eq", { t({ "from operator import eq", "" }) }),
    s("op-mul", { t({ "from operator import mul", "" }) }),
    s("op-ne", { t({ "from operator import ne", "" }) }),
    s("op-neg", { t({ "from operator import neg", "" }) }),
    s("op-or", { t({ "from operator import or_", "" }) }),
    s("op-sub", { t({ "from operator import sub", "" }) }),
    s("op-truediv", { t({ "from operator import truediv", "" }) }),

    -- optuna
    s("op-base-pruner", { t({ "from optuna.pruners import BasePruner", "" }) }),
    s("op-base-sampler", { t({ "from optuna.samplers import BaseSampler", "" }) }),
    s("op-study", { t({ "from optuna import Study", "" }) }),
    s("op-study-direction", { t({ "from optuna.study import StudyDirection", "" }) }),
    s("op-trial", { t({ "from optuna import Trial", "" }) }),

    -- os
    s("os-environ", { t({ "from os import environ", "" }) }),

    -- pathlib
    s("pa-path", { t({ "from pathlib import Path", "" }) }),

    -- polars
    s("im-pl", { t({ "import polars as pl", "" }) }),
    s("po-all-horizontal", { t({ "from polars import all_horizontal", "" }) }),
    s("po-any-horizontal", { t({ "from polars import any_horizontal", "" }) }),
    s("po-assert-frame-equal", { t({ "from polars.testing import assert_frame_equal", "" }) }),
    s("po-assert-series-equal", { t({ "from polars.testing import assert_series_equal", "" }) }),
    s("po-boolean", { t({ "from polars import Boolean", "" }) }),
    s("po-coalesce", { t({ "from polars import coalesce", "" }) }),
    s("po-col", { t({ "from polars import col", "" }) }),
    s("po-column-not-found-error", { t({ "from polars.exceptions import ColumnNotFoundError", "" }) }),
    s("po-compute-error", { t({ "from polars.exceptions import ComputeError", "" }) }),
    s("po-concat", { t({ "from polars import concat", "" }) }),
    s("po-dataframe", { t({ "from polars import DataFrame", "" }) }),
    s("po-date-range", { t({ "from polars import date_range", "" }) }),
    s("po-date-ranges", { t({ "from polars import date_ranges", "" }) }),
    s("po-datetime", { t({ "from polars import Datetime", "" }) }),
    s("po-datetime-range", { t({ "from polars import datetime_range", "" }) }),
    s("po-duration", { t({ "from polars import Duration", "" }) }),
    s("po-enum", { t({ "from polars import Enum", "" }) }),
    s("po-expr", { t({ "from polars import Expr", "" }) }),
    s("po-float64", { t({ "from polars import Float64", "" }) }),
    s("po-from-epoch", { t({ "from polars import from_epoch", "" }) }),
    s("po-int-range", { t({ "from polars import int_range", "" }) }),
    s("po-int-ranges", { t({ "from polars import int_ranges", "" }) }),
    s("po-int16", { t({ "from polars import Int16", "" }) }),
    s("po-int32", { t({ "from polars import Int32", "" }) }),
    s("po-int64", { t({ "from polars import Int64", "" }) }),
    s("po-int8", { t({ "from polars import Int8", "" }) }),
    s("po-into-expr", { t({ "from polars._typing import IntoExpr", "" }) }),
    s("po-into-expr-column", { t({ "from polars._typing import IntoExprColumn", "" }) }),
    s("po-list", { t({ "from polars import List", "" }) }),
    s("po-lit", { t({ "from polars import lit", "" }) }),
    s("po-max-horizontal", { t({ "from polars import max_horizontal", "" }) }),
    s("po-min-horizontal", { t({ "from polars import min_horizontal", "" }) }),
    s("po-no-rows-returned-error", { t({ "from polars.exceptions import NoRowsReturnedError", "" }) }),
    s("po-read-ipc", { t({ "from polars import read_ipc", "" }) }),
    s("po-schema-dict", { t({ "from polars._typing import SchemaDict", "" }) }),
    s("po-series", { t({ "from polars import Series", "" }) }),
    s("po-uint16", { t({ "from polars import UInt16", "" }) }),
    s("po-uint32", { t({ "from polars import UInt32", "" }) }),
    s("po-uint64", { t({ "from polars import UInt64", "" }) }),
    s("po-uint8", { t({ "from polars import UInt8", "" }) }),
    s("po-string", { t({ "from polars import String", "" }) }),
    s("po-struct", { t({ "from polars import struct", "" }) }),
    s("po-utf8", { t({ "from polars import Utf8", "" }) }),
    s("po-when", { t({ "from polars import when", "" }) }),

    -- pytest
    s("a0", { t({ "assert 0, '!!!'", "" }) }),
    s("a1", { t({ "from rich.pretty import pretty_repr", "", "assert 0, pretty_repr(locals())", "" }) }),
    s("mo", { t({ "@mark.only", "" }) }),
    s("mmo", { t({ "marks=mark.only", "" }) }),
    s("mms", { t({ "marks=mark.skip", "" }) }),
    s("mp", {
        t({ '@mark.parametrize("' }),
        i(1, "arg1"),
        t({ '", [param(' }),
        i(2, "param1"),
        t(")])"),
    }),
    s("mr10", { t({ "@mark.repeat(10)", "" }) }),
    s("ms", { t({ "@mark.skip", "" }) }),
    s("mx", { t({ "@mark.xfail", "" }) }),
    s("pyi", {
        t({ "from hypothesis import HealthCheck, Phase, given, reproduce_failure, settings", "" }),
        t({ "from pytest import RaisesGroup, fixture, mark, param, raises", "" }),
        t({ "from utilities.contextvars import set_global_breakpoint", "" }),
    }),
    s("py-approx", { t({ "from pytest import approx", "" }) }),
    s("py-fixture", { t({ "from pytest import fixture", "" }) }),
    s("py-mark", { t({ "from pytest import mark", "" }) }),
    s("py-param", { t({ "from pytest import param", "" }) }),
    s("py-raises", { t({ "from pytest import raises", "" }) }),
    s("py-raises-group", { t({ "from pytest import RaisesGroup", "" }) }),
    s("py-read-pickle", {
        t({
            "from utilities.pathlib import get_root",
            "from utilities.pickle import write_pickle",
            "",
        }),
        i(1, "obj"),
        t({
            ' = read_pickle(get_root().joinpath("notebooks", "pytest-tmp.gz"))',
            "",
        }),
    }),
    s("py-skip", { t({ "from pytest import skip", "" }) }),
    s("py-write-pickle", {
        t({
            "from utilities.pathlib import get_root",
            "from utilities.pickle import write_pickle",
            "",
            "write_pickle(",
        }),
        i(1, "obj"),
        t({
            ', get_root().joinpath("notebooks", "pytest-tmp.gz"), overwrite=True)',
            "",
        }),
    }),

    -- pytest-benchmark
    s("py-benchmark-fixture", { t({ "from pytest_benchmark.fixture import BenchmarkFixture", "" }) }),

    -- pytest-lazy-fixtures
    s("py-lf", { t({ "from pytest_lazy_fixtures import lf", "" }) }),

    -- pytest-regressions
    s(
        "py-dataframe-regression-fixture",
        { t({ "from pytest_regressions.dataframe_regression import DataFrameRegressionFixture", "" }) }
    ),

    -- random
    s("ra-randint", { t({ "from random import randint", "" }) }),
    s("ra-random", { t({ "from random import Random", "" }) }),
    s("ra-seed", { t({ "from random import seed", "" }) }),
    s("ra-shuffle", { t({ "from random import shuffle", "" }) }),

    -- re
    s("im-re", { t({ "import re", "" }) }),
    s("re-escape", { t({ "from re import escape", "" }) }),
    s("re-findall", { t({ "from re import findall", "" }) }),
    s("re-ignorecase", { t({ "from re import IGNORECASE", "" }) }),
    s("re-multiline", { t({ "from re import MULTILINE", "" }) }),
    s("re-search", { t({ "from re import search", "" }) }),
    s("re-sub", { t({ "from re import sub", "" }) }),

    -- redis
    s("re-redis", { t({ "from redis.asyncio import Redis", "" }) }),

    -- reprlib
    s("im-rep", { t({ "import reprlib", "" }) }),
    s("re-repr", { t({ "from reprlib import repr", "" }) }),

    -- rich
    s("rp", { t({ "from rich import print as rp", "" }) }),
    s("ri-pretty-repr", { t({ "from rich.pretty import pretty_repr", "" }) }),

    -- scripts
    s("if-name-main", { t({ 'if __name__ == "__main__":', "    main()", "" }) }),

    -- shutil
    s("sh-rmtree", { t({ "from shutil import rmtree", "" }) }),

    -- sqlalchemy
    s("sq-and", { t({ "from sqlalchemy import and_", "" }) }),
    s("sq-column", { t({ "from sqlalchemy import Column", "" }) }),
    s("sq-func", { t({ "from sqlalchemy import func", "" }) }),
    s("sq-insert", { t({ "from sqlalchemy import insert", "" }) }),
    s("sq-multiple-results-found", { t({ "from sqlalchemy.exc import MultipleResultsFound", "" }) }),
    s("sq-no-result-found", { t({ "from sqlalchemy.exc import NoResultFound", "" }) }),
    s("sq-or", { t({ "from sqlalchemy import or_", "" }) }),
    s("sq-select", { t({ "from sqlalchemy import select", "" }) }),
    s("sq-text", { t({ "from sqlalchemy import text", "" }) }),
    s("sq-url", { t({ "from sqlalchemy.engine.url import URL", "" }) }),

    -- statistics
    s("st-fmean", { t({ "from statistics import fmean", "" }) }),
    s("st-mean", { t({ "from statistics import mean", "" }) }),

    -- string
    s("st-ascii-letters", { t({ "from string import ascii_letters", "" }) }),
    s("st-template", { t({ "from string import Template", "" }) }),

    -- subprocess
    s("su-check-call", { t({ "from subprocess import check_call", "" }) }),
    s("su-check-output", { t({ "from subprocess import check_output", "" }) }),
    s("su-run", { t({ "from subprocess import run", "" }) }),

    -- sys
    s("sy-stdout", { t({ "from sys import stdout", "" }) }),

    -- tabulate
    s("ta-tabulate", { t({ "from tabulate import tabulate", "" }) }),

    -- tempfile
    s("te-temporary-directory", { t({ "from tempfile import TemporaryDirectory", "" }) }),

    -- tenacity
    s("te-retry", { t({ "from tenacity import retry", "" }) }),

    -- textwrap
    s("te-indent", { t({ "from textwrap import indent", "" }) }),

    -- threading
    s("th-rlock", { t({ "from threading import RLock", "" }) }),

    -- time
    s("ti-sleep", { t({ "from time import sleep", "" }) }),

    -- tqdm
    s("tq-tqdm", { t({ "from tqdm import tqdm", "" }) }),
    s("tq-trange", { t({ "from tqdm import trange", "" }) }),

    -- typed-settings
    s("ty-extended-ts-converter", { t({ "from utilities.typed_settings import ExtendedTSConverter", "" }) }),

    -- typing
    s("case-never", {
        t({ "case never:", "" }),
        t({ "    assert_never(never)", "" }),
    }),
    s("im-typing", { t({ "import typing", "" }) }),
    s("ty-any", { t({ "from typing import Any, cast", "" }) }),
    s("ty-cast", { t({ "from typing import Any, cast", "" }) }),
    s("ty-class-var", { t({ "from typing import ClassVar", "" }) }),
    s("ty-generic", { t({ "from typing import Generic", "" }) }),
    s("ty-literal", { t({ "from typing import Literal", "" }) }),
    s("ty-not-required", { t({ "from typing import NotRequired", "" }) }),
    s("ty-overload", { t({ "from typing import overload", "" }) }),
    s("ty-override", { t({ "from typing import override", "" }) }),
    s("ty-protocol", { t({ "from typing import Protocol", "" }) }),
    s("ty-required", { t({ "from typing import Required", "" }) }),
    s("ty-self", { t({ "from typing import Self", "" }) }),
    s("ty-type-var", { t({ "from typing import TypeVar", "" }) }),
    s("ty-typed-dict", { t({ "from typing import TypedDict", "" }) }),

    -- uuid
    s("uu-uuid", { t({ "from uuid import UUID", "" }) }),
    s("uu-uuid4", { t({ "from uuid import uuid4", "" }) }),

    -- utilities
    s("ut-add-listener", { t({ "from utilities.eventkit import add_listener", "" }) }),
    s("ut-always-iterable", { t({ "from utilities.iterables import always_iterable", "" }) }),
    s("ut-assume-does-not-raise", { t({ "from utilities.hypothesis import assume_does_not_raise", "" }) }),
    s("ut-bernoulli", { t({ "from utilities.random import bernoulli", "" }) }),
    s("ut-bounded-task-group", { t({ "from utilities.asyncio import BoundedTaskGroup", "" }) }),
    s("ut-bucket-mapping", { t({ "from utilities.more_itertools import bucket_mapping", "" }) }),
    s("ut-cache", { t({ "from utilities.functools import cache", "" }) }),
    s("ut-check-duplicates", { t({ "from utilities.iterables import check_duplicates", "" }) }),
    s("ut-check-polars-dataframe", { t({ "from utilities.polars import check_polars_dataframe", "" }) }),
    s("ut-convert-time-zone", { t({ "from utilities.polars import convert_time_zone", "" }) }),
    s("ut-counted-noun", { t({ "from utilities.inflect import counted_noun", "" }) }),
    s("ut-cpu-count", { t({ "from utilities.os import CPU_COUNT", "" }) }),
    s("ut-dataclass-repr", { t({ "from utilities.dataclasses import dataclass_repr", "" }) }),
    s("ut-dataclass-to-dict", { t({ "from utilities.dataclasses import dataclass_to_dict", "" }) }),
    s("ut-datetime-utc", { t({ "from utilities.polars import DatetimeUTC", "" }) }),
    s("ut-delta", { t({ "from utilities.types import Delta", "" }) }),
    s("ut-deserialize", { t({ "from utilities.orjson import deserialize", "" }) }),
    s("ut-duration", { t({ "from utilities.types import Duration", "" }) }),
    s("ut-enhanced-queue", { t({ "from utilities.asyncio import EnhancedQueue", "" }) }),
    s("ut-enhanced-task-group", { t({ "from utilities.asyncio import EnhancedTaskGroup", "" }) }),
    s("ut-ensure-date", { t({ "from utilities.functions import ensure_date", "" }) }),
    s("ut-ensure-float", { t({ "from utilities.functions import ensure_float", "" }) }),
    s("ut-ensure-int", { t({ "from utilities.functions import ensure_int", "" }) }),
    s("ut-ensure-member", { t({ "from utilities.functions import ensure_member", "" }) }),
    s("ut-ensure-not-none", { t({ "from utilities.functions import ensure_not_none", "" }) }),
    s("ut-ensure-number", { t({ "from utilities.functions import ensure_number", "" }) }),
    s("ut-ensure-str", { t({ "from utilities.text import ensure_str", "" }) }),
    s("ut-ensure-suffix", { t({ "from utilities.pathlib import ensure_suffix", "" }) }),
    s("ut-expr-like", { t({ "from utilities.polars import ExprLike", "" }) }),
    s("ut-expr-or-series", { t({ "from utilities.polars import ExprOrSeries", "" }) }),
    s("ut-extract-group", { t({ "from utilities.re import extract_group", "" }) }),
    s("ut-extract-groups", { t({ "from utilities.re import extract_groups", "" }) }),
    s("ut-format-comapct", { t({ "from utilities.whenever import format_compact", "" }) }),
    s("ut-get-args", { t({ "from utilities.typing import get_args", "" }) }),
    s("ut-get-class-name", { t({ "from utilities.functions import get_class_name", "" }) }),
    s("ut-get-env-var", { t({ "from utilities.os import get_env_var", "" }) }),
    s("ut-get-func-name", { t({ "from utilities.functions import get_func_name", "" }) }),
    s("ut-get-literal-elements", { t({ "from utilities.typing import get_literal_elements", "" }) }),
    s("ut-get-local-time-zone", { t({ "from utilities.tzlocal import get_local_time_zone", "" }) }),
    s("ut-get-logger", { t({ "from utilities.logging import get_logger", "" }) }),
    s("ut-get-now", { t({ "from utilities.whenever import get_now", "" }) }),
    s("ut-get-now-local", { t({ "from utilities.whenever import get_now_local", "" }) }),
    s("ut-get-repo-root", { t({ "from utilities.pathlib import get_repo_root", "" }) }),
    s("ut-get-root", { t({ "from utilities.pathlib import get_root", "" }) }),
    s("ut-get-state", { t({ "from utilities.random import get_state", "" }) }),
    s("ut-get-table", { t({ "from utilities.sqlalchemy import get_table", "" }) }),
    s("ut-get-today", { t({ "from utilities.whenever import get_today", "" }) }),
    s("ut-get-today-local", { t({ "from utilities.whenever import get_today_local", "" }) }),
    s("ut-groupby-lists", { t({ "from utilities.iterables import groupby_lists", "" }) }),
    s("ut-hong-kong", { t({ "from utilities.tzdata import HongKong", "" }) }),
    s("ut-hour", { t({ "from utilities.whenever import HOUR", "" }) }),
    s("ut-impossible-case-error", { t({ "from utilities.errors import ImpossibleCaseError", "" }) }),
    s("ut-insert-after", { t({ "from utilities.polars import insert_after", "" }) }),
    s("ut-insert-before", { t({ "from utilities.polars import insert_before", "" }) }),
    s("ut-insert-between", { t({ "from utilities.polars import insert_between", "" }) }),
    s("ut-insert-dataframe", { t({ "from utilities.sqlalchemy_polars import insert_dataframe", "" }) }),
    s("ut-insert-items", { t({ "from utilities.sqlalchemy import insert_items", "" }) }),
    s("ut-int-arrays", { t({ "from utilities.hypothesis import int_arrays", "" }) }),
    s("ut-is-pytest", { t({ "from utilities.pytest import is_pytest", "" }) }),
    s("ut-list-dir", { t({ "from utilities.pathlib import list_dir", "" }) }),
    s("ut-lists-fixed-length", { t({ "from utilities.hypothesis import lists_fixed_length", "" }) }),
    s("ut-log-level", { t({ "from utilities.types import LogLevel", "" }) }),
    s("ut-looper", { t({ "from utilities.asyncio import Looper", "" }) }),
    s("ut-maybe-iterable", { t({ "from utilities.types import MaybeIterable", "" }) }),
    s("ut-merge-mappings", { t({ "from utilities.iterables import merge_mappings", "" }) }),
    s("ut-merge-sets", { t({ "from utilities.iterables import merge_sets", "" }) }),
    s("ut-merge-str-mappings", { t({ "from utilities.iterables import merge_str_mappings", "" }) }),
    s("ut-millisecond", { t({ "from utilities.whenever import MILLISECOND", "" }) }),
    s("ut-minute", { t({ "from utilities.whenever import MINUTE", "" }) }),
    s("ut-month", { t({ "from utilities.whenever import Month", "" }) }),
    s("ut-number", { t({ "from utilities.types import Number", "" }) }),
    s("ut-one", { t({ "from utilities.iterables import one", "" }) }),
    s("ut-one-empty-error", { t({ "from utilities.iterables import OneEmptyError", "" }) }),
    s("ut-one-error", { t({ "from utilities.iterables import OneError", "" }) }),
    s("ut-one-non-unique-error", { t({ "from utilities.iterables import OneNonUniqueError", "" }) }),
    s("ut-pairs", { t({ "from utilities.hypothesis import pairs", "" }) }),
    s("ut-parse-date", { t({ "from utilities.whenever import parse_date", "" }) }),
    s("ut-parse-enum", { t({ "from utilities.enum import parse_enum", "" }) }),
    s("ut-partial", { t({ "from utilities.functools import partial", "" }) }),
    s("ut-partition", { t({ "from utilities.more_itertools import partition_list", "" }) }),
    s("ut-path-like", { t({ "from utilities.types import PathLike", "" }) }),
    s("ut-peekable", { t({ "from utilities.more_itertools import peekable", "" }) }),
    s("ut-period", { t({ "from utilities.period import Period", "" }) }),
    s("ut-read-json", { t({ "from utilities.orjson import read_json", "" }) }),
    s("ut-read-pickle", { t({ "from utilities.pickle import read_pickle", "" }) }),
    s("ut-read-object", { t({ "from utilities.orjson import read_object", "" }) }),
    s("ut-replace-non-sentinel", { t({ "from utilities.dataclasses import replace_non_sentinel", "" }) }),
    s("ut-round", { t({ "from utilities.math import round_", "" }) }),
    s("ut-safe-round", { t({ "from utilities.math import safe_round", "" }) }),
    s("ut-second", { t({ "from utilities.whenever import SECOND", "" }) }),
    s("ut-seed", { t({ "from utilities.types import Seed", "" }) }),
    s("ut-select-to-dataframe", { t({ "from utilities.sqlalchemy_polars import select_to_dataframe", "" }) }),
    s("ut-sentinel", { t({ "from utilities.sentinel import sentinel, Sentinel", "" }) }),
    s("ut-sequence-str", { t({ "from utilities.types import SequenceStr" }) }),
    s("ut-serialize", { t({ "from utilities.orjson import serialize", "" }) }),
    s("ut-serialize-duration", { t({ "from utilities.whenever import serialize_duration", "" }) }),
    s("ut-serialize-zoned-datetime", { t({ "from utilities.whenever import serialize_zoned_datetime" }) }),
    s("ut-setup-logging", { t({ "from utilities.logging import setup_logging", "" }) }),
    s("ut-show", { t({ "from utilities.jupyter import show", "" }) }),
    s("ut-shuffle", { t({ "from utilities.random import shuffle", "" }) }),
    s("ut-sleep-td", { t({ "from utilities.asyncio import sleep_td", "" }) }),
    s("ut-str-mapping", { t({ "from utilities.types import StrMapping", "" }) }),
    s("ut-strip-and-dedent", { t({ "from utilities.text import strip_and_dedent", "" }) }),
    s("ut-struct-dtype", { t({ "from utilities.polars import struct_dtype", "" }) }),
    s(
        "ut-suppress-super-object-attribute-error",
        { t({ "from utilities.contextlib import suppress_super_object_attribute_error", "" }) }
    ),
    s("ut-suppress-warnings", { t({ "from utilities.warnings import suppress_warnings", "" }) }),
    s("ut-system-random", { t({ "from utilities.random import SYSTEM_RANDOM", "" }) }),
    s("ut-take", { t({ "from utilities.iterables import take", "" }) }),
    s("ut-temp-environ", { t({ "from utilities.os import temp_environ", "" }) }),
    s("ut-temp-paths", { t({ "from utilities.hypothesis import temp_paths", "" }) }),
    s("ut-temporary-directory", { t({ "from utilities.tempfile import TemporaryDirectory", "" }) }),
    s("ut-text-ascii", { t({ "from utilities.hypothesis import text_ascii", "" }) }),
    s("ut-text-ascii-lower", { t({ "from utilities.hypothesis import text_ascii_lower", "" }) }),
    s("ut-text-ascii-upper", { t({ "from utilities.hypothesis import text_ascii_upper", "" }) }),
    s("ut-throttle", { t({ "from utilities.pytest import throttle", "" }) }),
    s("ut-timeout-td", { t({ "from utilities.asyncio import timeout_td", "" }) }),
    s("ut-timer", { t({ "from utilities.timer import Timer", "" }) }),
    s("ut-tokyo", { t({ "from utilities.tzdata import Tokyo", "" }) }),
    s("ut-to-logger", { t({ "from utilities.logging import to_logger", "" }) }),
    s("ut-trace", { t({ "from utilities.traceback import trace", "" }) }),
    s("ut-transpose", { t({ "from utilities.iterables import transpose", "" }) }),
    s("ut-try-reify-expr", { t({ "from utilities.polars import try_reify_expr", "" }) }),
    s("ut-unique-str", { t({ "from utilities.text import unique_str", "" }) }),
    s("ut-us-central", { t({ "from utilities.tzdata import USCentral", "" }) }),
    s("ut-us-eastern", { t({ "from utilities.tzdata import USEastern", "" }) }),
    s("ut-utc", { t({ "from utilities.zoneinfo import UTC", "" }) }),
    s("ut-version", { t({ "from utilities.version import Version", "" }) }),
    s("ut-week", { t({ "from utilities.whenever import WEEK", "" }) }),
    s("ut-write-json", { t({ "from utilities.orjson import write_json", "" }) }),
    s("ut-write-pickle", { t({ "from utilities.pickle import write_pickle", "" }) }),
    s("ut-writer", { t({ "from utilities.atomicwrites import writer", "" }) }),
    s("ut-yield-fields", { t({ "from utilities.dataclasses import yield_fields", "" }) }),
    s("ut-yield-shelf", { t({ "from utilities.shelve import yield_shelf", "" }) }),
    s("ut-zoned-datetime-dtype", { t({ "from utilities.polars import zoned_datetime_dtype", "" }) }),
    s("ut-zoned-datetime-period-dtype", { t({ "from utilities.polars import zoned_datetime_period_dtype", "" }) }),
    s("ut-zoned-datetimes", { t({ "from utilities.hypothesis import zoned_datetimes", "" }) }),

    -- whenever
    s("wh-date", { t({ "from whenever import Date", "" }) }),
    s("wh-date-delta", { t({ "from whenever import DateDelta", "" }) }),
    s("wh-date-time-delta", { t({ "from whenever import DateTimeDelta", "" }) }),
    s("wh-plain-date-time", { t({ "from whenever import PlainDateTime", "" }) }),
    s("wh-time", { t({ "from whenever import Time", "" }) }),
    s("wh-time-delta", { t({ "from whenever import TimeDelta", "" }) }),
    s("wh-zoned-date-time", { t({ "from whenever import ZonedDateTime", "" }) }),

    -- zoneinfo
    s("zo-zoneinfo", { t({ "from zoneinfo import ZoneInfo", "" }) }),
})

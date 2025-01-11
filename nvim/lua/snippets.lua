local ls = require("luasnip")
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("python", {
    -- asyncio
    s("as-create-task", { t({ "from asyncio import create_task", "" }) }),
    s("as-get-event-loop", { t({ "from asyncio import get_event_loop", "" }) }),
    s("as-sleep", { t({ "from asyncio import sleep", "" }) }),
    s("as-task-group", { t({ "from asyncio import TaskGroup", "" }) }),

    -- beartype
    s("be-beartype", { t({ "from beartype import beartype", "" }) }),

    -- beartype
    s("bi-bidict", { t({ "from bidict import bidict", "" }) }),

    -- breakpoints
    s("bp", { t({ "breakpoint()", "" }) }),
    s("if-name-main", { t({ 'if __name__ == "__main__":', "    main()", "" }) }),
    s("rnie", { t({ "raise NotImplementedError", "" }) }),

    -- cachetools
    s("ca-ttl-cache", { t({ "from cachetools.func import ttl_cache", "" }) }),

    -- click
    s("cl-argument", { t({ "from click import argument", "" }) }),
    s("cl-cli-runner", { t({ "from click.testing import CliRunner", "" }) }),
    s("cl-command", { t({ "from click import command", "" }) }),
    s("cl-option", { t({ "from click import option", "" }) }),

    -- collections
    s("co-callable", { t({ "from collections.abc import Callable", "" }) }),
    s("co-iterable", { t({ "from collections.abc import Iterable", "" }) }),
    s("co-iterator", { t({ "from collections.abc import Iterator", "" }) }),
    s("co-mapping", { t({ "from collections.abc import Mapping", "" }) }),
    s("co-sequence", { t({ "from collections.abc import Sequence", "" }) }),

    -- contextlib
    s("co-asynccontextmanager", { t({ "from contextlib import asynccontextmanager", "" }) }),
    s("co-contextmanager", { t({ "from contextlib import contextmanager", "" }) }),
    s("co-suppress", { t({ "from contextlib import suppress", "" }) }),
    s("co-redirect-stderr", { t({ "from contextlib import redirect_stderr", "" }) }),
    s("co-redirect-stdout", { t({ "from contextlib import redirect_stdout", "" }) }),

    -- dataclasses
    s("da-asdict", { t({ "from dataclasses import asdict", "" }) }),
    s("da-astuple", { t({ "from dataclasses import astuple", "" }) }),
    s("da-dataclass", { t({ "from dataclasses import dataclass", "" }) }),
    s("da-field", { t({ "from dataclasses import field", "" }) }),
    s("da-replace", { t({ "from dataclasses import replace", "" }) }),
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

    -- frozendict
    s("fr-frozendict", { t({ "from frozendict import frozendict", "" }) }),

    -- functools
    s("fu-partial", { t({ "from functools import partial", "" }) }),
    s("fu-reduce", { t({ "from functools import reduce", "" }) }),
    s("fu-wraps", { t({ "from functools import wraps", "" }) }),

    -- future
    s("fu-annotations", { t({ "from __future__ import annotations", "" }) }),

    -- humanize
    s("hu-naturaldelta", { t({ "from humanize import naturaldelta", "" }) }),
    s("hu-naturaltime", { t({ "from humanize import naturaltime", "" }) }),

    -- hypothesis
    s("hy-assume", { t({ "from hypothesis import assume", "" }) }),
    s("hy-booleans", { t({ "from hypothesis.strategies import booleans", "" }) }),
    s("hy-builds", { t({ "from hypothesis.strategies import builds", "" }) }),
    s("hy-composite", { t({ "from hypothesis.strategies import composite", "" }) }),
    s("hy-data", { t({ "from hypothesis.strategies import data, DataObject", "" }) }),
    s("hy-dates", { t({ "from hypothesis.strategies import dates", "" }) }),
    s("hy-datetimes", { t({ "from hypothesis.strategies import datetimes", "" }) }),
    s("hy-floats", { t({ "from hypothesis.strategies import floats", "" }) }),
    s("hy-given", { t({ "from hypothesis import given", "" }) }),
    s("hy-integers", { t({ "from hypothesis.strategies import integers", "" }) }),
    s("hy-invalid-argument", { t({ "from hypothesis.errors import InvalidArgument", "" }) }),
    s("hy-lists", { t({ "from hypothesis.strategies import lists", "" }) }),
    s("hy-none", { t({ "from hypothesis.strategies import none", "" }) }),
    s("hy-phase", { t({ "from hypothesis import Phase", "" }) }),
    s("hy-reproduce-failure", { t({ "from hypothesis import reproduce_failure", "" }) }),
    s("hy-sampled-from", { t({ "from hypothesis.strategies import sampled_from", "" }) }),
    s("hy-sets", { t({ "from hypothesis.strategies import sets", "" }) }),
    s("hy-settings", { t({ "from hypothesis import settings", "" }) }),
    s("hy-tuples", { t({ "from hypothesis.strategies import tuples", "" }) }),
    s("settings-filter-too-much", { t({ "@settings(suppress_health_check={HealthCheck.filter_too_much})", "" }) }),
    s("settings-generate-only", { t({ "@settings(phases={Phase.generate})", "" }) }),
    s("settings-max-examples", { t({ "@settings(max_examples=1)", "" }) }),

    -- ib-async
    s("ib-cont-future", { t({ "from ib_async import ContFuture", "" }) }),
    s("ib-crypto", { t({ "from ib_async import Crypto", "" }) }),
    s("ib-forex", { t({ "from ib_async import Forex", "" }) }),
    s("ib-future", { t({ "from ib_async import Future", "" }) }),
    s("ib-ib", { t({ "from ib_async import IB", "" }) }),
    s("ib-index", { t({ "from ib_async import Index", "" }) }),
    s("ib-stock", { t({ "from ib_async import Stock", "" }) }),

    -- itertools
    s("it-accumulate", { t({ "from itertools import accumulate", "" }) }),
    s("it-chain", { t({ "from itertools import chain", "" }) }),
    s("it-count", { t({ "from itertools import count", "" }) }),
    s("it-cycle", { t({ "from itertools import cycle", "" }) }),
    s("it-groupby", { t({ "from itertools import groupby", "" }) }),
    s("it-product", { t({ "from itertools import product", "" }) }),
    s("it-starmap", { t({ "from itertools import starmap", "" }) }),

    -- logging
    s("lo-formatter", { t({ "from logging import Formatter", "" }) }),
    s("lo-get-logger", { t({ "from logging import getLogger", "" }) }),
    s("lo-handler", { t({ "from logging import Handler", "" }) }),
    s("lo-stream-handler", { t({ "from logging import StreamHandler", "" }) }),

    -- loguru
    s("lo-logger", { t({ "from loguru import logger", "" }) }),

    -- math
    s("ma-inf", { t({ "from math import inf", "" }) }),
    s("ma-nan", { t({ "from math import nan", "" }) }),

    -- more-itertools
    s("mi-iterate", { t({ "from more_itertools import iterate", "" }) }),
    s("mi-partition", { t({ "from more_itertools import partition", "" }) }),
    s("mi-split-at", { t({ "from more_itertools import split_after", "" }) }),

    -- operator
    s("op-add", { t({ "from operator import add", "" }) }),
    s("op-and", { t({ "from operator import and_", "" }) }),
    s("op-eq", { t({ "from operator import eq", "" }) }),
    s("op-mul", { t({ "from operator import mul", "" }) }),
    s("op-neg", { t({ "from operator import neg", "" }) }),
    s("op-or", { t({ "from operator import or_", "" }) }),
    s("op-sub", { t({ "from operator import sub", "" }) }),
    s("op-truediv", { t({ "from operator import truediv", "" }) }),

    -- pathlib
    s("pa-path", { t({ "from pathlib import Path", "" }) }),

    -- polars
    s("im-pl", { t({ "import polars as pl", "" }) }),
    s("po-assert-frame-equal", { t({ "from polars.testing import assert_frame_equal", "" }) }),
    s("po-assert-series-equal", { t({ "from polars.testing import assert_series_equal", "" }) }),
    s("po-boolean", { t({ "from polars import Boolean", "" }) }),
    s("po-coalesce", { t({ "from polars import coalesce", "" }) }),
    s("po-col", { t({ "from polars import col", "" }) }),
    s("po-compute-error", { t({ "from polars.exceptions import ComputeError", "" }) }),
    s("po-concat", { t({ "from polars import concat", "" }) }),
    s("po-dataframe", { t({ "from polars import DataFrame", "" }) }),
    s("po-date-range", { t({ "from polars import date_range", "" }) }),
    s("po-date-ranges", { t({ "from polars import date_ranges", "" }) }),
    s("po-datetime", { t({ "from polars import Datetime", "" }) }),
    s("po-datetime-range", { t({ "from polars import datetime_range", "" }) }),
    s("po-enum", { t({ "from polars import Enum", "" }) }),
    s("po-expr", { t({ "from polars import Expr", "" }) }),
    s("po-float64", { t({ "from polars import Float64", "" }) }),
    s("po-from-epoch", { t({ "from polars import from_epoch", "" }) }),
    s("po-int-range", { t({ "from polars import int_range", "" }) }),
    s("po-int-ranges", { t({ "from polars import int_ranges", "" }) }),
    s("po-int64", { t({ "from polars import Int64", "" }) }),
    s("po-list", { t({ "from polars import List", "" }) }),
    s("po-lit", { t({ "from polars import lit", "" }) }),
    s("po-max-horizontal", { t({ "from polars import max_horizontal", "" }) }),
    s("po-min-horizontal", { t({ "from polars import min_horizontal", "" }) }),
    s("po-read-ipc", { t({ "from polars import read_ipc", "" }) }),
    s("po-series", { t({ "from polars import Series", "" }) }),
    s("po-string", { t({ "from polars import String", "" }) }),
    s("po-struct", { t({ "from polars import struct", "" }) }),
    s("po-utf8", { t({ "from polars import Utf8", "" }) }),
    s("po-when", { t({ "from polars import when", "" }) }),

    -- pytest
    s("a0", { t({ "from rich.pretty import pretty_repr", "", "assert 0, pretty_repr(locals(), max_length=5)" }) }),
    s("mo", { t({ "@mark.only", "" }) }),
    s("mmo", { t({ "marks=mark.only", "" }) }),
    s("mp", {
        t({ '@mark.parametrize("' }),
        i(1, "arg1"),
        t({ '", [param(' }),
        i(2, "param1"),
        t(")])"),
    }),
    s("ms", { t({ "@mark.skip", "" }) }),
    s("mx", { t({ "@mark.xfail", "" }) }),
    s("py-approx", { t({ "from pytest import approx", "" }) }),
    s("py-fixture", { t({ "from pytest import fixture", "" }) }),
    s("py-mark", { t({ "from pytest import mark, param", "" }) }),
    s("py-param", { t({ "from pytest import param", "" }) }),
    s("py-raises", { t({ "from pytest import raises", "" }) }),
    s("py-write-pickle", {
        t({
            "from utilities.git import get_repo_root",
            "from utilities.pickle import write_pickle",
            "",
            "write_pickle(",
        }),
        i(1, "obj"),
        t({
            ', get_repo_root().joinpath("notebooks", "pytest-tmp.gz"), overwrite=True)',
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
    s("re-search", { t({ "from re import search", "" }) }),
    s("re-sub", { t({ "from re import sub", "" }) }),

    -- redis
    s("re-redis", { t({ "from redis import Redis", "" }) }),

    -- reprlib
    s("im-rep", { t({ "import reprlib", "" }) }),
    s("re-repr", { t({ "from reprlib import repr", "" }) }),

    -- rich
    s("rp", { t({ "from rich import print as rp", "" }) }),
    s("ri-pretty-repr", { t({ "from rich.pretty import pretty_repr", "" }) }),

    -- shutil
    s("sh-rmtree", { t({ "from shutil import rmtree", "" }) }),

    -- sqlalchemy
    s("sq-and", { t({ "from sqlalchemy import and_", "" }) }),
    s("sq-func", { t({ "from sqlalchemy import func", "" }) }),
    s("sq-or", { t({ "from sqlalchemy import or_", "" }) }),
    s("sq-select", { t({ "from sqlalchemy import select", "" }) }),
    s("sq-text", { t({ "from sqlalchemy import text", "" }) }),

    -- subprocess
    s("su-check-call", { t({ "from subprocess import check_call", "" }) }),
    s("su-check-output", { t({ "from subprocess import check_output", "" }) }),
    s("su-run", { t({ "from subprocess import run", "" }) }),

    -- sys
    s("sy-stdout", { t({ "from sys import stdout", "" }) }),

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

    -- typing
    s("im-typing", { t({ "import typing", "" }) }),
    s("ty-any", { t({ "from typing import Any", "" }) }),
    s("ty-cast", { t({ "from typing import cast", "" }) }),
    s("ty-generic", { t({ "from typing import Generic", "" }) }),
    s("ty-literal", { t({ "from typing import Literal", "" }) }),
    s("ty-not-required", { t({ "from typing import NotRequired", "" }) }),
    s("ty-overload", { t({ "from typing import overload", "" }) }),
    s("ty-protocol", { t({ "from typing import Protocol", "" }) }),
    s("ty-required", { t({ "from typing import Required", "" }) }),
    s("ty-type-var", { t({ "from typing import TypeVar", "" }) }),
    s("ty-typed-dict", { t({ "from typing import TypedDict", "" }) }),

    -- typing-extensions
    s("ty-override", { t({ "from typing_extensions import override", "" }) }),

    -- uuid
    s("uu-uuid", { t({ "from uuid import UUID", "" }) }),

    -- utilities
    s("ut-add-listener", { t({ "from utilities.eventkit import add_listener", "" }) }),
    s("ut-always-iterable", { t({ "from utilities.iterables import always_iterable", "" }) }),
    s("ut-asdict-without-defaults", { t({ "from utilities.dataclasses import asdict_without_defaults", "" }) }),
    s("ut-cache", { t({ "from utilities.functools import cache", "" }) }),
    s("ut-check-duplicates", { t({ "from utilities.iterables import check_duplicates", "" }) }),
    s("ut-check-polars-dataframe", { t({ "from utilities.polars import check_polars_dataframe", "" }) }),
    s("ut-date-to-datetime", { t({ "from utilities.datetime import date_to_datetime", "" }) }),
    s("ut-duration", { t({ "from utilities.types import Duration", "" }) }),
    s("ut-ensure-date", { t({ "from utilities.functions import ensure_date", "" }) }),
    s("ut-ensure-float", { t({ "from utilities.functions import ensure_float", "" }) }),
    s("ut-ensure-int", { t({ "from utilities.functions import ensure_int", "" }) }),
    s("ut-ensure-member", { t({ "from utilities.functions import ensure_member", "" }) }),
    s("ut-ensure-not-none", { t({ "from utilities.functions import ensure_not_none", "" }) }),
    s("ut-ensure-number", { t({ "from utilities.functions import ensure_number", "" }) }),
    s("ut-ensure-str", { t({ "from utilities.text import ensure_str", "" }) }),
    s("ut-extract-group", { t({ "from utilities.re import extract_group", "" }) }),
    s("ut-extract-groups", { t({ "from utilities.re import extract_groups", "" }) }),
    s("ut-get-args", { t({ "from utilities.typing import get_args", "" }) }),
    s("ut-get-func-name", { t({ "from utilities.functions import get_func_name", "" }) }),
    s("ut-get-now", { t({ "from utilities.datetime import get_now", "" }) }),
    s("ut-get-repo-root", { t({ "from utilities.git import get_repo_root", "" }) }),
    s("ut-get-table", { t({ "from utilities.sqlalchemy import get_table", "" }) }),
    s("ut-get-today", { t({ "from utilities.datetime import get_today", "" }) }),
    s("ut-hong-kong", { t({ "from utilities.zoneinfo import HongKong", "" }) }),
    s("ut-impossible-case-error", { t({ "from utilities.errors import ImpossibleCaseError", "" }) }),
    s("ut-insert-dataframe", { t({ "from utilities.sqlalchemy_polars import insert_dataframe", "" }) }),
    s("ut-insert-items", { t({ "from utilities.sqlalchemy import insert_items", "" }) }),
    s("ut-int-arrays", { t({ "from utilities.hypothesis import int_arrays", "" }) }),
    s("ut-list-dir", { t({ "from utilities.pathlib import list_dir", "" }) }),
    s("ut-lists-fixed-length", { t({ "from utilities.hypothesis import lists_fixed_length", "" }) }),
    s("ut-log-level", { t({ "from utilities.logging import LogLevel", "" }) }),
    s("ut-minute", { t({ "from utilities.datetime import MINUTE", "" }) }),
    s("ut-number", { t({ "from utilities.types import Number", "" }) }),
    s("ut-one", { t({ "from utilities.iterables import one", "" }) }),
    s("ut-one-empty-error", { t({ "from utilities.iterables import OneEmptyError", "" }) }),
    s("ut-one-non-unique-error", { t({ "from utilities.iterables import OneNonUniqueError", "" }) }),
    s("ut-parse-date", { t({ "from utilities.whenever import parse_date", "" }) }),
    s("ut-partial", { t({ "from utilities.functools import partial", "" }) }),
    s("ut-path-like", { t({ "from utilities.pathlib import PathLike", "" }) }),
    s("ut-period", { t({ "from utilities.period import Period", "" }) }),
    s("ut-read-pickle", { t({ "from utilities.pickle import read_pickle", "" }) }),
    s("ut-replace-non-sentinel", { t({ "from utilities.dataclasses import replace_non_sentinel", "" }) }),
    s("ut-repr-without-defaults", { t({ "from utilities.dataclasses import repr_without_defaults", "" }) }),
    s("ut-safe-round", { t({ "from utilities.math import safe_round", "" }) }),
    s("ut-select-to-dataframe", { t({ "from utilities.sqlalchemy_polars import select_to_dataframe", "" }) }),
    s("ut-sentinel", { t({ "from utilities.sentinel import sentinel, Sentinel", "" }) }),
    s("ut-setup-logging", { t({ "from utilities.logging import setup_logging", "" }) }),
    s("ut-show", { t({ "from utilities.jupyter import show", "" }) }),
    s("ut-strip-and-dedent", { t({ "from utilities.text import strip_and_dedent", "" }) }),
    s("ut-system-random", { t({ "from utilities.random import SYSTEM_RANDOM", "" }) }),
    s("ut-take", { t({ "from utilities.iterables import take", "" }) }),
    s("ut-temporary-directory", { t({ "from utilities.tempfile import TemporaryDirectory", "" }) }),
    s("ut-throttle", { t({ "from utilities.pytest import throttle", "" }) }),
    s("ut-timeout-dur", { t({ "from utilities.asyncio import timeout_dur", "" }) }),
    s("ut-timer", { t({ "from utilities.timer import Timer", "" }) }),
    s("ut-tokyo", { t({ "from utilities.zoneinfo import Tokyo", "" }) }),
    s("ut-transpose", { t({ "from utilities.iterables import transpose", "" }) }),
    s("ut-us-central", { t({ "from utilities.zoneinfo import USCentral", "" }) }),
    s("ut-us-eastern", { t({ "from utilities.zoneinfo import USEastern", "" }) }),
    s("ut-utc", { t({ "from utilities.zoneinfo import UTC", "" }) }),
    s("ut-write-pickle", { t({ "from utilities.pickle import write_pickle", "" }) }),
    s("ut-writer", { t({ "from utilities.atomicwrites import writer", "" }) }),
    s("ut-yield-fields", { t({ "from utilities.dataclasses import yield_fields", "" }) }),
    s("ut-zoned-datetime", { t({ "from utilities.polars import zoned_datetime", "" }) }),

    -- whenever
    s("wh-date-delta", { t({ "from whenever import DateDelta", "" }) }),
    s("wh-date-time-delta", { t({ "from whenever import DateTimeDelta", "" }) }),
    s("wh-local-date-time", { t({ "from whenever import LocalDateTime", "" }) }),
    s("wh-time", { t({ "from whenever import Time", "" }) }),
    s("wh-time-delta", { t({ "from whenever import TimeDelta", "" }) }),
    s("wh-zoned-date-time", { t({ "from whenever import ZonedDateTime", "" }) }),

    -- zoneinfo
    s("zo-zoneinfo", { t({ "from zoneinfo import ZoneInfo", "" }) }),
})

local ls = require("luasnip")
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("python", {
    -- asyncio
    s("as-get-event-loop", { t({ "from asyncio import get_event_loop", "" }) }),

    -- beartype
    s("be-beartype", { t({ "from beartype import beartype", "" }) }),

    -- breakpoints
    s("bp", { t({ "breakpoint()", "" }) }),
    s("index-bp", {
        t({ "if index == " }),
        i(1, "Index"),
        t({ ":", "    breakpoint()" }),
    }),
    s("if-name-main", { t({ 'if __name__ == "__main__":', "   main()", "" }) }),
    s("rnie", { t({ "raise NotImplementedError" }) }),

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

    -- contextlib
    s("co-suppress", { t({ "from contextlib import suppress", "" }) }),

    -- dataclasses
    s("da-asdict", { t({ "from dataclasses import asdict", "" }) }),
    s("da-astuple", { t({ "from dataclasses import astuple", "" }) }),
    s("da-dataclass", { t({ "from dataclasses import dataclass", "" }) }),
    s("da-field", { t({ "from dataclasses import field", "" }) }),
    s("da-replace", { t({ "from dataclasses import replace", "" }) }),
    s("dataclass-fr-kw", {
        t({ "@dataclass(frozen=True, kw_only=True)", "" }),
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

    -- functools
    s("fu-partial", { t({ "from functools import partial", "" }) }),
    s("fu-reduce", { t({ "from functools import reduce", "" }) }),

    -- future
    s("fu-annotations", { t({ "from __future__ import annotations", "" }) }),

    -- humanize
    s("hu-naturaldelta", { t({ "from humanize import naturaldelta", "" }) }),
    s("hu-naturaltime", { t({ "from humanize import naturaltime", "" }) }),

    -- hypothesis
    s("hy-assume", { t({ "from hypothesis import assume", "" }) }),
    s("hy-booleans", { t({ "from hypothesis.strategies import booleans", "" }) }),
    s("hy-composite", { t({ "from hypothesis.strategies import composite", "" }) }),
    s("hy-data", { t({ "from hypothesis.strategies import data, DataObject", "" }) }),
    s("hy-dates", { t({ "from hypothesis.strategies import dates", "" }) }),
    s("hy-datetimes", { t({ "from hypothesis.strategies import datetimes", "" }) }),
    s("hy-given", { t({ "from hypothesis import given", "" }) }),
    s("hy-integers", { t({ "from hypothesis.strategies import integers", "" }) }),
    s("hy-invalid-argument", { t({ "from hypothesis.errors import InvalidArgument", "" }) }),
    s("hy-lists", { t({ "from hypothesis.strategies import lists", "" }) }),
    s("hy-reproduce-failure", { t({ "from hypothesis import reproduce_failure", "" }) }),
    s("hy-sampled-from", { t({ "from hypothesis.strategies import sampled_from", "" }) }),
    s("hy-settings", { t({ "from hypothesis import settings", "" }) }),
    s("hy-tuples", { t({ "from hypothesis.strategies import tuples", "" }) }),
    s("settings-filter-too-much", { t({ "@settings(suppress_health_check={HealthCheck.filter_too_much})", "" }) }),
    s("settings-generate-only", { t({ "@settings(phases={Phase.generate})", "" }) }),
    s("settings-max-examples", { t({ "@settings(max_examples=1)", "" }) }),

    -- itertools
    s("it-accumulate", { t({ "from itertools import accumulate", "" }) }),
    s("it-chain", { t({ "from itertools import chain", "" }) }),
    s("it-groupby", { t({ "from itertools import groupby", "" }) }),
    s("it-product", { t({ "from itertools import product", "" }) }),

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
    s("op-and", { t({ "from operator import and_", "" }) }),
    s("op-or", { t({ "from operator import or_", "" }) }),

    -- pathlib
    s("pa-path", { t({ "from pathlib import Path", "" }) }),

    -- polars
    s("im-pl", { t({ "import polars as pl", "" }) }),
    s("po-assert-frame-equal", { t({ "from polars.testing import assert_frame_equal", "" }) }),
    s("po-assert-series-equal", { t({ "from polars.testing import assert_series_equal", "" }) }),
    s("po-boolean", { t({ "from polars import Boolean", "" }) }),
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
    s("po-series", { t({ "from polars import Series", "" }) }),
    s("po-struct", { t({ "from polars import struct", "" }) }),
    s("po-utf8", { t({ "from polars import Utf8", "" }) }),
    s("po-when", { t({ "from polars import when", "" }) }),

    -- pytest
    s("mark-only", { t({ "@mark.only", "" }) }),
    s("mark-parametrize", {
        t({ '@mark.parametrize("' }),
        i(1, "arg1"),
        t({ '", [param(' }),
        i(2, "param1"),
        t(")])"),
    }),
    s("mark-skip", { t({ "@mark.skip", "" }) }),
    s("py-approx", { t({ "from pytest import approx", "" }) }),
    s("py-fixture", { t({ "from pytest import fixture", "" }) }),
    s("py-mark", { t({ "from pytest import mark, param", "" }) }),
    s("py-param", { t({ "from pytest import param", "" }) }),
    s("py-raises", { t({ "from pytest import raises", "" }) }),

    -- pytest-benchmark
    s("py-benchmark-fixture", { t({ "from pytest_benchmark.fixture import BenchmarkFixture", "" }) }),

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
    s("re-search", { t({ "from re import search", "" }) }),

    -- redis
    s("re-redis", { t({ "from redis import Redis", "" }) }),

    -- rich
    s("ri-print", { t({ "from rich import print", "" }), t({ "" }), t({ "print(" }), i(1, "Values"), t({ ")", "" }) }),

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
    s("te-temporary-directory", { t({ "from utilities.tempfile import TemporaryDirectory", "" }) }),

    -- time
    s("ti-sleep", { t({ "from time import sleep", "" }) }),

    -- typing
    s("ty-any", { t({ "from typing import Any", "" }) }),
    s("ty-cast", { t({ "from typing import cast", "" }) }),
    s("ty-generic", { t({ "from typing import Generic", "" }) }),
    s("ty-literal", { t({ "from typing import Literal", "" }) }),
    s("ty-overload", { t({ "from typing import overload", "" }) }),
    s("ty-protocol", { t({ "from typing import Protocol", "" }) }),
    s("ty-type-var", { t({ "from typing import TypeVar", "" }) }),

    -- typing-extensions
    s("ty-override", { t({ "from typing_extensions import override", "" }) }),

    -- uuid
    s("uu-uuid", { t({ "from uuid import UUID", "" }) }),

    -- utilities
    s("ut-always-iterable", { t({ "from utilities.more_itertools import always_iterable", "" }) }),
    s("ut-check-polars-dataframe", { t({ "from utilities.polars import check_polars_dataframe", "" }) }),
    s("ut-date-to-datetime", { t({ "from utilities.datetime import date_to_datetime", "" }) }),
    s("ut-ensure-date", { t({ "from utilities.types import ensure_date", "" }) }),
    s("ut-ensure-float", { t({ "from utilities.types import ensure_float", "" }) }),
    s("ut-ensure-int", { t({ "from utilities.types import ensure_int", "" }) }),
    s("ut-ensure-member", { t({ "from utilities.types import ensure_member", "" }) }),
    s("ut-ensure-not-none", { t({ "from utilities.types import ensure_not_none", "" }) }),
    s("ut-ensure-number", { t({ "from utilities.types import ensure_number", "" }) }),
    s("ut-ensure-str", { t({ "from utilities.text import ensure_str", "" }) }),
    s("ut-extract-group", { t({ "from utilities.re import extract_group", "" }) }),
    s("ut-extract-groups", { t({ "from utilities.re import extract_groups", "" }) }),
    s("ut-get-local-timezone", { t({ "from utilities.datetime import local_timezone", "" }) }),
    s("ut-get-now", { t({ "from utilities.datetime import get_now", "" }) }),
    s("ut-get-repo-root", { t({ "from utilities.git import get_repo_root", "" }) }),
    s("ut-get-table", { t({ "from utilities.sqlalchemy import get_table", "" }) }),
    s("ut-get-today", { t({ "from utilities.datetime import get_today", "" }) }),
    s("ut-hong-kong", { t({ "from utilities.zoneinfo import HONG_KONG", "" }) }),
    s("ut-impossible-case-error", { t({ "from utilities.errors import ImpossibleCaseError", "" }) }),
    s("ut-index-s", { t({ "utilities.pandas import IndexS", "" }) }),
    s("ut-insert-dataframe", { t({ "from utilities.sqlalchemy_polars import insert_dataframe", "" }) }),
    s("ut-insert-items", { t({ "from utilities.sqlalchemy import insert_items", "" }) }),
    s("ut-int-arrays", { t({ "from utilities.hypothesis import int_arrays", "" }) }),
    s("ut-utc", { t({ "from utilities.zoneinfo import UTC", "" }) }),
    s("ut-list-dir", { t({ "from utilities.pathlib import list_dir", "" }) }),
    s("ut-lists-fixed-length", { t({ "from utilities.hypothesis import lists_fixed_length", "" }) }),
    s("ut-memoize", { t({ "from utilities.atools import memoize", "" }) }),
    s("ut-one", { t({ "from utilities.iterables import one", "" }) }),
    s("ut-partial", { t({ "from utilities.functools import partial", "" }) }),
    s("ut-parse-date", { t({ "from utilities.datetime import parse_date", "" }) }),
    s("ut-read-pickle", { t({ "from utilities.pickle import read_pickle", "" }) }),
    s("ut-refresh-memoized", { t({ "from utilities.atools import refresh_memoized", "" }) }),
    s("ut-select-to-dataframe", { t({ "from utilities.sqlalchemy_polars import select_to_dataframe", "" }) }),
    s("ut-strip-and-dedent", { t({ "from utilities.text import strip_and_dedent", "" }) }),
    s("ut-take", { t({ "from utilities.iterables import take", "" }) }),
    s("ut-timer", { t({ "from utilities.timer import Timer", "" }) }),
    s("ut-throttle", { t({ "from utilities.pytest import throttle", "" }) }),
    s("ut-tokyo", { t({ "from utilities.zoneinfo import TOKYO", "" }) }),
    s("ut-write-pickle", { t({ "from utilities.pickle import write_pickle", "" }) }),
    s("ut-writer", { t({ "from utilities.atomicwrites import writer", "" }) }),

    -- zoneinfo
    s("zo-zoneinfo", { t({ "from zoneinfo import ZoneInfo", "" }) }),
})

local ls = require("luasnip")
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("python", {
    s("bp", { t({ "breakpoint()", "" }) }),

    -- miscellaneous
    s("fu-annotations", { t({ "from __future__ import annotations", "" }) }),

    -- beartype
    s("be-beartype", { t({ "from beartype import beartype", "" }) }),

    -- click
    s("cl-argument", { t({ "from click import argument", "" }) }),
    s("cl-command", { t({ "from click import command", "" }) }),
    s("cl-option", { t({ "from click import option", "" }) }),

    -- contextlib
    s("co-suppress", { t({ "from contextlib import suppress", "" }) }),

    -- dataclasses
    s("da-dataclass", { t({ "from dataclasses import dataclass", "" }) }),
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
    s("dt-utc", { t({ "from datetime import UTC", "" }) }),

    -- enum
    s("en-auto", { t({ "from enum import auto", "" }) }),
    s("en-enum", { t({ "from enum import Enum", "" }) }),

    -- functools
    s("fu-partial", { t({ "from functools import partial", "" }) }),
    s("fu-reduce", { t({ "from functools import reduce", "" }) }),

    -- hypothesis
    s("hy-assume", { t({ "from hypothesis import assume", "" }) }),
    s("hy-data", { t({ "from hypothesis.strategies import data, DataObject", "" }) }),
    s("hy-given", { t({ "from hypothesis import given", "" }) }),
    s("hy-integers", { t({ "from hypothesis.strategies import integers", "" }) }),
    s("hy-lists", { t({ "from hypothesis.strategies import lists", "" }) }),
    s("hy-reproduce-failure", { t({ "from hypothesis import reproduce_failure", "" }) }),

    -- itertools
    s("it-accumulate", { t({ "from itertools import accumulate", "" }) }),
    s("it-chain", { t({ "from itertools import chain", "" }) }),
    s("it-product", { t({ "from itertools import product", "" }) }),

    -- loguru
    s("lo-logger", { t({ "from loguru import logger", "" }) }),

    -- more-itertools
    s("mi-iterate", { t({ "from more_itertools import iterate", "" }) }),
    s("mi-partition", { t({ "from more_itertools import partition", "" }) }),
    s("mi-split-at", { t({ "from more_itertools import split_after", "" }) }),

    -- pathlib
    s("pa-path", { t({ "from pathlib import Path", "" }) }),

    -- pytest
    s("mark-parametrize", {
        t({ '@mark.parametrize("' }),
        i(1, "arg1"),
        t({ '"), [param(' }),
        i(2, "param1"),
        t(")])"),
    }),
    s("py-approx", { t({ "from pytest import approx", "" }) }),
    s("py-fixture", { t({ "from pytest import fixture", "" }) }),
    s("py-mark", { t({ "from pytest import mark, param", "" }) }),
    s("py-raises", { t({ "from pytest import raises", "" }) }),

    -- pytest-benchmark
    s("py-benchmark-fixture", { t({ "from pytest_benchmark.fixture import BenchmarkFixture", "" }) }),

    -- rich
    s("ri-print", { t({ "from rich import print", "" }) }),

    -- sqlalchemy
    s("sq-func", { t({ "from sqlalchemy import func", "" }) }),
    s("sq-select", { t({ "from sqlalchemy import select", "" }) }),
    s("sq-text", { t({ "from sqlalchemy import text", "" }) }),

    -- subprocess
    s("su-check-call", { t({ "from subprocess import check_call", "" }) }),
    s("su-check-output", { t({ "from subprocess import check_output", "" }) }),
    s("su-run", { t({ "from subprocess import run", "" }) }),

    -- time
    s("ti-sleep", { t({ "from time import sleep", "" }) }),

    -- typing
    s("ty-any", { t({ "from typing import Any", "" }) }),
    s("ty-cast", { t({ "from typing import cast", "" }) }),
    s("ty-literal", { t({ "from typing import Literal", "" }) }),
    s("ty-overload", { t({ "from typing import overload", "" }) }),

    -- typing-extensions
    s("ty-override", { t({ "from typing_extensions import override", "" }) }),

    -- utilities
    s("ut-always-iterable", { t({ "from utilities.more_itertools import always_iterable", "" }) }),
    s("ut-check-polars-dataframe", { t({ "from utilities.polars import check_polars_dataframe", "" }) }),
    s("ut-date-to-datetime", { t({ "from utilities.datetime import date_to_datetime", "" }) }),
    s("ut-ensure-date", { t({ "from utilities.types import ensure_date", "" }) }),
    s("ut-ensure-float", { t({ "from utilities.types import ensure_float", "" }) }),
    s("ut-ensure-int", { t({ "from utilities.types import ensure_int", "" }) }),
    s("ut-ensure-not-none", { t({ "from utilities.types import ensure_not_none", "" }) }),
    s("ut-ensure-number", { t({ "from utilities.types import ensure_number", "" }) }),
    s("ut-ensure-str", { t({ "from utilities.text import ensure_str", "" }) }),
    s("ut-extract-group", { t({ "from utilities.re import extract_group", "" }) }),
    s("ut-extract-groups", { t({ "from utilities.re import extract_groups", "" }) }),
    s("ut-get-now", { t({ "from utilities.datetime import get_now", "" }) }),
    s("ut-get-repo-root", { t({ "from utilities.git import get_repo_root", "" }) }),
    s("ut-get-table", { t({ "from utilities.sqlalchemy import get_table", "" }) }),
    s("ut-hong-kong", { t({ "from utilities.zoneinfo import HONG_KONG", "" }) }),
    s("ut-impossible-case-error", { t({ "from utilities.errors import ImpossibleCaseError", "" }) }),
    s("ut-index-s", { t({ "utilities.pandas import IndexS", "" }) }),
    s("ut-insert-dataframe", { t({ "from utilities.sqlalchemy_polars import insert_dataframe", "" }) }),
    s("ut-insert-items", { t({ "from utilities.sqlalchemy import insert_items", "" }) }),
    s("ut-int-arrays", { t({ "from utilities.hypothesis import int_arrays", "" }) }),
    s("ut-list-dir", { t({ "from utilities.pathlib import list_dir", "" }) }),
    s("ut-lists-fixed-length", { t({ "from utilities.hypothesis import lists_fixed_length", "" }) }),
    s("ut-one", { t({ "from utilities.iterables import one", "" }) }),
    s("ut-partial", { t({ "from utilities.functools import partial", "" }) }),
    s("ut-select-to-dataframe", { t({ "from utilities.sqlalchemy_polars import select_to_dataframe", "" }) }),
    s("ut-strip-and-dedent", { t({ "from utilities.text import strip_and_dedent", "" }) }),
    s("ut-take", { t({ "from utilities.iterables import take", "" }) }),
    s("ut-throttle", { t({ "from utilities.pytest import throttle", "" }) }),
    s("ut-tokyo", { t({ "from utilities.zoneinfo import TOKYO", "" }) }),
    s("ut-writer", { t({ "from utilities.atomicwrites import writer", "" }) }),

    -- zoneinfo
    s("zo-zoneinfo", { t({ "from zoneinfo import ZoneInfo", "" }) }),
})

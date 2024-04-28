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

    --click
    s("cl-argument", { t({ "from click import argument", "" }) }),
    s("cl-command", { t({ "from click import command", "" }) }),
    s("cl-option", { t({ "from click import option", "" }) }),

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

    -- hypothesis
    s("hy-given", { t({ "from hypothesis import given", "" }) }),
    s("hy-integers", { t({ "from hypothesis.strategies import integers", "" }) }),
    s("hy-reproduce-failure", { t({ "from hypothesis import reproduce_failure", "" }) }),

    -- itertools
    s("it-chain", { t({ "from itertools import chain", "" }) }),

    -- loguru
    s("lo-logger", { t({ "from loguru import logger", "" }) }),

    -- more-itertools
    s("mi-partition", { t({ "from more_itertools import partition", "" }) }),
    s("mi-split-at", { t({ "from more_itertools import split_after", "" }) }),

    -- pathlib
    s("pa-path", { t({ "from pathlib import Path", "" }) }),

    -- pytest
    s("py-fixture", { t({ "from pytest import fixture", "" }) }),
    s("py-mark", { t({ "from pytest import mark", "" }) }),
    s("py-param", { t({ "from pytest import param", "" }) }),

    -- sqlalchemy
    s("sq-func", { t({ "from sqlalchemy import func", "" }) }),

    -- subprocess
    s("su-check-call", { t({ "from subprocess import check_call", "" }) }),
    s("su-check-output", { t({ "from subprocess import check_output", "" }) }),
    s("su-run", { t({ "from subprocess import run", "" }) }),

    -- typing
    s("ty-any", { t({ "from typing import Any", "" }) }),
    s("ty-cast", { t({ "from typing import cast", "" }) }),
    s("ty-literal", { t({ "from typing import Literal", "" }) }),

    -- utilities
    s("ut-check-polars-dataframe", { t({ "from utilities.polars import check_polars_dataframe", "" }) }),
    s("ut-date-to-datetime", { t({ "from utilities.datetime import date_to_datetime", "" }) }),
    s("ut-ensure-not-none", { t({ "from utilities.types import ensure_not_none", "" }) }),
    s("ut-ensure-str", { t({ "from utilities.text import ensure_str", "" }) }),
    s("ut-extract-group", { t({ "from utilities.re import extract_group", "" }) }),
    s("ut-extract-groups", { t({ "from utilities.re import extract_groups", "" }) }),
    s("ut-get-now", { t({ "from utilities.datetime import get_now", "" }) }),
    s("ut-get-table", { t({ "from utilities.sqlalchemy import get_table", "" }) }),
    s("ut-hong-kong", { t({ "from utilities.zoneinfo import HONG_KONG", "" }) }),
    s("ut-index-s", { t({ "utilities.pandas import IndexS", "" }) }),
    s("ut-insert-dataframe", { t({ "from utilities.sqlalchemy_polars import insert_dataframe", "" }) }),
    s("ut-insert-items", { t({ "from utilities.sqlalchemy import insert_items", "" }) }),
    s("ut-list-dir", { t({ "from utilities.pathlib import list_dir", "" }) }),
    s("ut-one", { t({ "from utilities.iterables import one", "" }) }),
    s("ut-partial", { t({ "from utilities.functools import partial", "" }) }),
    s("ut-select-to-dataframe", { t({ "from utilities.sqlalchemy_polars import select_to_dataframe", "" }) }),
    s("ut-throttle", { t({ "from utilities.pytest import throttle", "" }) }),

    -- zoneinfo
    s("zo-zoneinfo", { t({ "from zoneinfo import ZoneInfo", "" }) }),
})

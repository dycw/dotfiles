local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("python", {
    s("bp", { t("breakpoint()") }),

    -- miscellaneous
    s("imdt", { t("import datetime as dt") }),
    s("fu-annotations", { t("from __future__ import annotations") }),

    -- dataclasses
    s("da-dataclasses", { t("from dataclasses import dataclass") }),

    -- loguru
    s("lo-logger", { t("from loguru import logger") }),

    -- typing
    s("ty-any", { t("from typing import Any") }),
    s("ty-cast", { t("from typing import cast") }),

    -- utilities
    s("ut-check-polars-dataframe", { t("from utilities.polars import check_polars_dataframe") }),
    s("ut-ensure-not-none", { t("from utilities.types import ensure_not_none") }),
    s("ut-ensure-str", { t("from utilities.text import ensure_str") }),
    s("ut-extract-group", { t("from utilities.re import extract_group") }),
    s("ut-extract-groups", { t("from utilities.re import extract_groups") }),
    s("ut-get-table", { t("from utilities.sqlalchemy import get_table") }),
    s("ut-hong-kong", { t("from utilities.zoneinfo import HONG_KONG") }),
    s("ut-index-s", { t("utilities.pandas import IndexS") }),
    s("ut-insert-dataframe", { t("from utilities.sqlalchemy_polars import insert_dataframe") }),
    s("ut-select-to-dataframe", { t("from utilities.sqlalchemy_polars import select_to_dataframe") }),
    s("ut-insert-items", { t("from utilities.sqlalchemy import insert_items") }),
    s("ut-list-dir", { t("from utilities.pathlib import list_dir") }),
    s("ut-one", { t("from utilities.iterables import one") }),
    s("ut-partial", { t("from utilities.functools import partial") }),
})

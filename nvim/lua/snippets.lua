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

    -- utilities
    s("ut-ensure-str", { t("from utilities.text import ensure_str") }),
    s("ut-index-s", { t("utilities.pandas import IndexS") }),
    s("ut-one", { t("from utilities.iterables import one") }),
    s("ut-partial", { t("from utilities.functools import partial") }),
    s("ut-check-polars-dataframe", { t("from utilities.polars import check_polars_dataframe") }),
    s("ut-ensure-not-none", { t("from utilities.types import ensure_not_none") }),
    s("ut-insert-items", { t("from utilities.sqlalchemy import insert_items") }),
    s("ut-insert-dataframe", { t("from utilities.sqlalchemy_polars import insert_dataframe") }),
})

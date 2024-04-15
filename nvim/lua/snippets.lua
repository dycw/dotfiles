local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("python", {
    s("bp", { t("breakpoint()") }),
    s("imdt", { t("import datetime as dt") }),

    -- utilities
    s("ut-ensure-str", { t("from utilities.text import ensure_str") }),
    s("ut-one", { t("from utilities.itertools import one") }),
})

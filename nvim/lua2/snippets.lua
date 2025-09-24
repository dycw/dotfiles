local ls = require("luasnip")
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("python", {

    -- errors
    s("no-t201", { t({ "# noqa: T201", "" }) }),
    s("ex-n801", { t({ "(Exception): ...  # noqa: N801", "" }) }),

    -- pytest
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

    -- typing
    s("case-never", {
        t({ "case never:", "" }),
        t({ "    assert_never(never)", "" }),
    }),
})

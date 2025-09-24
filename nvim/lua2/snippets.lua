local ls = require("luasnip")
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("python", {

    -- errors
    s("no-t201", { t({ "# noqa: T201", "" }) }),
    s("ex-n801", { t({ "(Exception): ...  # noqa: N801", "" }) }),

    -- pytest
    s("pyi", {
        t({ "from hypothesis import HealthCheck, Phase, given, reproduce_failure, settings", "" }),
        t({ "from pytest import RaisesGroup, approx, fixture, mark, param, raises", "" }),
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
    s("with-raises", {
        t("with raises("),
        i(1, "Exception"),
        t(', match="'),
        i(2, "match"),
        t('") as error:'),
        t(""),
        t("    pass"),
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

    -- typing
    s("case-never", {
        t({ "case never:", "" }),
        t({ "    assert_never(never)", "" }),
    }),
})

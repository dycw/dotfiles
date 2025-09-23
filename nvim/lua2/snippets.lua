local ls = require("luasnip")
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("python", {

    -- breakpoints
    s("sgb", {
        t({ "from utilities.contextvars import set_global_breakpoint", "" }),
        t({ "set_global_breakpoint()", "" }),
    }),

    -- dataclasses
    s("da-dataclass-kw", { t({ "@dataclass(kw_only=True)", "" }) }),
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

    -- errors
    s("no-t201", { t({ "# noqa: T201", "" }) }),
    s("ex-n801", { t({ "(Exception): ...  # noqa: N801", "" }) }),

    -- hypothesis
    s("da-data-object", { t({ "data: DataObject" }) }),
    s("settings-filter-too-much", { t({ "@settings(suppress_health_check={HealthCheck.filter_too_much})", "" }) }),
    s(
        "settings-function-scoped-fixture",
        { t({ "@settings(suppress_health_check={HealthCheck.function_scoped_fixture})", "" }) }
    ),
    s("settings-generate-only", { t({ "@settings(phases={Phase.generate})", "" }) }),
    s("settings-max-examples", { t({ "@settings(max_examples=1)", "" }) }),

    -- logging
    s("logger-name", { t({ "from utilities.logging import to_logger", "", "_LOGGER = to_logger(__name__)", "" }) }),
    s("logger-adapter", { t({ "logger: LoggerAdapter = field(init=False)", "" }) }),

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

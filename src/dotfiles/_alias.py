from __future__ import annotations

import json
from typing import TYPE_CHECKING, assert_never, override

from libcst import (
    CSTVisitor,
    Import,
    ImportFrom,
    Module,
    SimpleStatementLine,
    parse_module,
)
from utilities.core import kebab_case, to_logger
from utilities.errors import ImpossibleCaseError
from utilities.libcst import generate_import_from, parse_import
from utilities.subprocess import run

if TYPE_CHECKING:
    from utilities.types import StrDict

_LOGGER = to_logger(__name__)


def generate_alias(text: str, /) -> None:
    module = parse_module(text)
    collector = _ImportCollector()
    _ = module.visit(collector)
    data: StrDict = {}
    for imp in collector.imports:
        match imp:
            case Import():
                raise NotImplementedError
            case ImportFrom():
                key, value = _import_from_to_dict(imp)
                data[key] = value
            case never:
                assert_never(never)
    raw_json = json.dumps(data)
    formatted_json = run("prettier", "--parser", "json", input=raw_json, return_=True)
    _LOGGER.info("\n%s", formatted_json)


class _ImportCollector(CSTVisitor):
    @override
    def __init__(self) -> None:
        super().__init__()
        self.imports: list[Import | ImportFrom] = []

    @override
    def visit_Import(self, node: Import) -> None:
        self._append(node)

    @override
    def visit_ImportFrom(self, node: ImportFrom) -> None:
        self._append(node)

    def _append(self, node: Import | ImportFrom) -> None:
        for parsed in parse_import(node):
            if parsed.name is None:
                raise ValueError(parsed)
            node = generate_import_from(parsed.module, parsed.name)
            self.imports.append(node)


def _import_from_to_dict(imp: ImportFrom, /) -> tuple[str, StrDict]:
    key = _get_code(imp).rstrip("\n")
    value: StrDict = {}
    value["body"] = f"{key}\n"
    (parsed,) = parse_import(imp)
    prefix_head = parsed.module.split(".")[0][:2]
    if parsed.name is None:
        raise ImpossibleCaseError(case=[f"{parsed.name=}"])
    prefix_tail = kebab_case(parsed.name)
    value["prefix"] = f"{prefix_head}-{prefix_tail}"
    return key, value


def _get_code(imp: Import | ImportFrom, /) -> str:
    return Module(body=[SimpleStatementLine(body=[imp])]).code


__all__ = ["generate_alias"]

from __future__ import annotations

import json
from typing import TYPE_CHECKING, override

from libcst import (
    CSTVisitor,
    Import,
    ImportFrom,
    Module,
    SimpleStatementLine,
    parse_module,
)
from utilities.core import kebab_case, to_logger
from utilities.libcst import generate_import, generate_import_from, parse_import
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
        key, value = _to_key_value(imp)
        data[key] = value
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
                node = generate_import(parsed.module)
            else:
                node = generate_import_from(parsed.module, parsed.name)
            self.imports.append(node)


def _to_key_value(imp: Import | ImportFrom, /) -> tuple[str, StrDict]:
    key = _get_code(imp).rstrip("\n")
    value: StrDict = {}
    value["body"] = f"{key}\n"
    (parsed,) = parse_import(imp)
    module = parsed.module.split(".")[0].strip("_")
    if parsed.name is None:
        prefix = f"im-{module}"
    else:
        kebab_name = kebab_case(parsed.name)
        prefix = f"{module[:2]}-{kebab_name}"
    value["prefix"] = prefix
    return key, value


def _get_code(imp: Import | ImportFrom, /) -> str:
    return Module(body=[SimpleStatementLine(body=[imp])]).code


__all__ = ["generate_alias"]

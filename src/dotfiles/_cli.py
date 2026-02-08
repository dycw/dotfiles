from __future__ import annotations

from click import group, version_option
from utilities.click import CONTEXT_SETTINGS, Str, argument
from utilities.core import is_pytest, set_up_logging

from dotfiles import __version__
from dotfiles._alias import generate_alias


@group(**CONTEXT_SETTINGS)
@version_option(version=__version__)
def cli() -> None: ...


@cli.command("alias", help="Generate a Python alias", **CONTEXT_SETTINGS)
@argument("text", type=Str())
def alias_sub_cmd(*, text: str) -> None:
    if is_pytest():
        return
    set_up_logging(__name__, root=True, log_version=__version__)
    generate_alias(text)

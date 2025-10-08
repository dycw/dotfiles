from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.lib import add_to_known_hosts, setup_pdb, setup_psql

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def setup_common(
    *, pdbrc: PathLike | None = None, psqlrc: PathLike | None = None
) -> None:
    _LOGGER.info("Setting up common...")
    add_to_known_hosts()
    setup_pdb(pdbrc=pdbrc)
    setup_psql(psqlrc=psqlrc)


__all__ = ["setup_common"]

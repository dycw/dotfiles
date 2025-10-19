from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.lib import (
    add_to_known_hosts,
    setup_pdb,
    setup_psql,
    setup_resolv_conf,
    setup_ssh,
    setup_sshd,
)

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def setup_common(
    *,
    pdbrc: PathLike | None = None,
    permit_root_login: bool = False,
    psqlrc: PathLike | None = None,
    resolv_conf: PathLike | None = None,
    resolv_conf_immutable: bool = False,
) -> None:
    _LOGGER.info("Setting up common...")
    add_to_known_hosts()
    setup_pdb(pdbrc=pdbrc)
    setup_psql(psqlrc=psqlrc)
    setup_resolv_conf(resolv_conf=resolv_conf, immutable=resolv_conf_immutable)
    setup_ssh()
    setup_sshd(permit_root_login=permit_root_login)


__all__ = ["setup_common"]

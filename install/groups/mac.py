from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.groups.common import setup_common
from install.lib import (
    install_brew,
    install_curl,
    install_fish,
    install_fzf,
    install_git,
)

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def setup_mac(
    *,
    fish_config: PathLike | None = None,
    fish_env: PathLike | None = None,
    fish_git: PathLike | None = None,
    fish_work: PathLike | None = None,
    fzf_fish: PathLike | None = None,
    git_config: PathLike | None = None,
    git_ignore: PathLike | None = None,
    pdbrc: PathLike | None = None,
    psqlrc: PathLike | None = None,
) -> None:
    _LOGGER.info("Setting up Mac...")
    setup_common(pdbrc=pdbrc, psqlrc=psqlrc)
    install_brew()
    install_git(config=git_config, ignore=git_ignore)
    install_curl()  # after brew
    install_fish(  # after brew
        config=fish_config, env=fish_env, git=fish_git, work=fish_work
    )
    install_fzf(fzf_fish=fzf_fish)  # after brew
    # keyboard international
    # mouse up/down


__all__ = ["setup_mac"]

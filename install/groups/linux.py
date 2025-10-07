from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.groups.common import setup_common
from install.lib import install_curl, install_fish, install_fzf, install_git

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def setup_linux(
    *,
    fish_config: PathLike | None = None,
    fish_env: PathLike | None = None,
    fish_git: PathLike | None = None,
    fish_work: PathLike | None = None,
    fzf_fish: PathLike | None = None,
    git_config: PathLike | None = None,
    git_ignore: PathLike | None = None,
    pdbrc: PathLike | None = None,
) -> None:
    _LOGGER.info("Setting up Linux...")
    setup_common(pdbrc=pdbrc)
    install_curl()
    install_fzf(fzf_fish=fzf_fish)
    install_git(config=git_config, ignore=git_ignore)
    install_fish(  # after curl
        config=fish_config, env=fish_env, git=fish_git, work=fish_work
    )


__all__ = ["setup_linux"]

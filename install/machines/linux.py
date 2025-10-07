from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.lib import install_fish, install_fzf, install_git
from install.machines.common import setup_common

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
) -> None:
    _LOGGER.info("Setting up Linux...")
    setup_common()
    install_fish(config=fish_config, env=fish_env, git=fish_git, work=fish_work)
    install_fzf(fzf_fish=fzf_fish)
    install_git(config=git_config, ignore=git_ignore)


__all__ = ["setup_linux"]

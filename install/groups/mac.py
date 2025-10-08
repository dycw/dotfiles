from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.groups.common import setup_common
from install.lib import (
    install_age,
    install_bat,
    install_bottom,
    install_brew,
    install_bump_my_version,
    install_delta,
    install_direnv,
    install_dust,
    install_eza,
    install_fd,
    install_fish,
    install_fzf,
    install_gh,
    install_ghostty,
    install_git,
    install_glab,
    install_gsed,
    install_iperf3,
    install_jq,
    install_just,
    install_luacheck,
    install_macchanger,
    install_neovim,
    install_pre_commit,
    install_pyright,
    install_ripgrep,
    install_ruff,
    install_shellcheck,
    install_shfmt,
    install_sops,
    install_starship,
    install_stylua,
    install_syncthing,
    install_tailscale,
    install_tmux,
    install_uv,
    install_vim,
    install_watch,
    install_yq,
    install_zoxide,
    setup_sshd,
)

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def setup_mac(
    *,
    age_secret_key: PathLike | None = None,
    bottom_toml: PathLike | None = None,
    fd_ignore: PathLike | None = None,
    fish_config: PathLike | None = None,
    fish_env: PathLike | None = None,
    fish_git: PathLike | None = None,
    fish_work: PathLike | None = None,
    fzf_fish: PathLike | None = None,
    git_config: PathLike | None = None,
    git_ignore: PathLike | None = None,
    nvim_dir: PathLike | None = None,
    pdbrc: PathLike | None = None,
    psqlrc: PathLike | None = None,
    ripgreprc: PathLike | None = None,
    starship_toml: PathLike | None = None,
    tailscale_auth_key: PathLike | None = None,
    tmux_conf_oh_my_tmux: PathLike | None = None,
    tmux_conf_local: PathLike | None = None,
) -> None:
    _LOGGER.info("Setting up Mac...")
    setup_common(pdbrc=pdbrc, psqlrc=psqlrc)
    install_brew()
    install_git(config=git_config, ignore=git_ignore)
    install_age()  # after brew
    install_bat()  # after brew
    install_bottom(bottom_toml=bottom_toml)  # after brew
    install_bump_my_version()  # after brew
    install_delta()  # after brew
    install_direnv()  # after brew
    # !unsure    install_dropbox()  # after brew
    install_dust()  # after brew
    install_eza()  # after brew
    install_fd(ignore=fd_ignore)
    install_fish(  # after brew
        config=fish_config, env=fish_env, git=fish_git, work=fish_work
    )
    install_fzf(fzf_fish=fzf_fish)  # after brew
    install_gh()  # after brew
    install_ghostty()  # after brew
    install_glab()  # after brew
    install_gsed()  # after brew
    install_iperf3()  # after brew
    install_jq()  # after brew
    install_just()  # after brew
    install_luacheck()  # after brew
    install_macchanger()  # after brew
    install_neovim(nvim_dir=nvim_dir)  # after brew
    install_pre_commit()  # after brew
    install_pyright()  # after brew
    install_ripgrep(ripgreprc=ripgreprc)  # after brew
    install_ruff()  # after brew
    install_shellcheck()  # after brew
    install_shfmt()  # after brew
    install_sops(age_secret_key=age_secret_key)  # after brew
    install_starship(starship_toml=starship_toml)  # after brew
    install_stylua()  # after brew
    install_syncthing()  # after brew
    install_tailscale(auth_key=tailscale_auth_key)  # after brew
    install_tmux(  # after brew
        tmux_conf_oh_my_tmux=tmux_conf_oh_my_tmux, tmux_conf_local=tmux_conf_local
    )
    install_uv()  # after brew
    install_vim()  # after brew
    install_watch()  # after brew
    install_yq()  # after brew
    install_zoxide()  # after brew
    setup_sshd()  # after gsed
    # keyboard international
    # mouse up/down


__all__ = ["setup_mac"]

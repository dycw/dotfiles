from __future__ import annotations

from logging import getLogger
from typing import TYPE_CHECKING

from install.groups.common import setup_common
from install.lib import (
    install_age,
    install_bottom,
    install_build_essential,
    install_bump_my_version,
    install_curl,
    install_delta,
    install_direnv,
    install_docker,
    install_dust,
    install_eza,
    install_fd,
    install_fish,
    install_fzf,
    install_gh,
    install_git,
    install_gitweb,
    install_iperf3,
    install_jq,
    install_just,
    install_luacheck,
    install_luarocks,
    install_macchanger,
    install_neovim,
    install_neovim_dependencies,
    install_pre_commit,
    install_pyright,
    install_ripgrep,
    install_rsync,
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
    install_wezterm,
    install_yq,
    install_zoxide,
    setup_sshd,
)

if TYPE_CHECKING:
    from install.types import PathLike

_LOGGER = getLogger(__name__)


def setup_linux(
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
    wezterm_lua: PathLike | None = None,
) -> None:
    _LOGGER.info("Setting up Linux...")
    setup_common(pdbrc=pdbrc, psqlrc=psqlrc)
    setup_sshd()
    install_age()
    install_build_essential()
    install_curl()
    install_delta()
    install_direnv()
    install_dust()
    install_eza()
    install_fd(ignore=fd_ignore)
    install_fzf(fzf_fish=fzf_fish)
    install_gh()
    install_git(config=git_config, ignore=git_ignore)
    install_iperf3()
    install_jq()
    install_just()
    install_luarocks()
    install_macchanger()
    install_neovim(nvim_dir=nvim_dir)
    install_neovim_dependencies()
    install_ripgrep(ripgreprc=ripgreprc)
    install_rsync()
    install_shellcheck()
    install_shfmt()
    install_starship(starship_toml=starship_toml)
    install_syncthing()
    install_tmux(
        tmux_conf_oh_my_tmux=tmux_conf_oh_my_tmux, tmux_conf_local=tmux_conf_local
    )
    install_vim()
    install_zoxide()
    install_docker()  # after curl
    install_fish(  # after curl
        config=fish_config, env=fish_env, git=fish_git, work=fish_work
    )
    install_tailscale(auth_key=tailscale_auth_key)  # after curl
    install_uv()  # after curl
    install_wezterm(wezterm_lua=wezterm_lua)  # after curl
    install_bottom(bottom_toml=bottom_toml)  # after curl, jq
    install_gitweb()  # after curl, jq
    install_sops(age_secret_key=age_secret_key)  # after curl, jq
    install_stylua()  # after curl, jq
    install_yq()  # after curl, jq
    install_luacheck()  # after lurocks
    install_bump_my_version()  # after uv
    install_pre_commit()  # after uv
    install_pyright()  # after uv
    install_ruff()  # after uv


__all__ = ["setup_linux"]

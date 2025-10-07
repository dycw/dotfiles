#!/usr/bin/env python3
from logging import getLogger
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import assert_never
from zipfile import ZipFile

# constants


_LOGGER = getLogger(__name__)


# library


def install_caffeine() -> None:
    if have_command("caffeine"):
        _LOGGER.debug("'caffeine' is already installed")
        return
    _LOGGER.info("Installing 'caffeine'...")
    apt_install("caffeine")


def install_docker() -> None:
    if have_command("docker"):
        _LOGGER.debug("'docker' is already installed")
        return
    _LOGGER.info("Installing 'docker'...")
    packages = [
        "docker.io",
        "docker-doc",
        "docker-compose",
        "podman-docker",
        "containerd",
        "runc",
    ]
    run_commands(*(f"sudo apt-get remove {p}" for p in packages))
    apt_install("ca-certificates", "curl")
    run_commands(
        "sudo install -m 0755 -d /etc/apt/keyrings",
        "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",
        "sudo chmod a+r /etc/apt/keyrings/docker.asc",
        'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null',
    )
    apt_install(
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin",
    )
    run_commands("sudo usermod -aG docker $USER")


def install_fd_find(*, config: bool = False) -> None:
    if have_command("fdfind"):
        _LOGGER.debug("'fd-find' is already installed")
    else:
        _LOGGER.info("Installing 'fd-find'...")
        apt_install("fd-find")
    if config:
        symlink("~/.config/fd/ignore", f"{_get_script_dir()}/fd/ignore")


def install_fzf(*, fzf_fish: bool = False) -> None:
    if have_command("fzf"):
        _LOGGER.debug("'fzf' is already installed")
    else:
        _LOGGER.info("Installing 'fzf'...")
        match System.identify():
            case System.mac:
                brew_install("fzf")
            case System.linux:
                apt_install("fzf")
            case never:
                assert_never(never)
    if fzf_fish:
        for path in full_path(f"{_get_local_bin()}/fzf/fzf.fish/functions").iterdir():
            _copyfile(path, f"~/.config/fish/functions/{path.name}")


def install_gh() -> None:
    if have_command("gh"):
        _LOGGER.debug("'gh' is already installed")
        return
    _LOGGER.info("Installing 'gh'...")
    apt_install("gh")


def install_glab() -> None:
    if have_command("glab"):
        _LOGGER.debug("'glab' is already installed")
    else:
        _LOGGER.info("Installing 'glab'...")
        apt_install("glab")
    path_to = full_path("~/work/infra/gitlab/cli.yml")
    if path_to.exists():
        symlink("~/.config/glab-cli/config.yml", path_to)


def install_jq() -> None:
    if have_command("jq"):
        _LOGGER.debug("'jq' is already installed")
        return
    _LOGGER.info("Installing 'jq'...")
    apt_install("jq")


def install_just() -> None:
    if have_command("just"):
        _LOGGER.debug("'just' is already installed")
        return
    _LOGGER.info("Installing 'just'...")
    apt_install("just")


def install_luacheck() -> None:
    if have_command("luacheck"):
        _LOGGER.debug("'luacheck' is already installed")
        return
    install_luarocks()
    _LOGGER.info("Installing 'luacheck'...")
    _luarocks_install("luacheck")


def install_luarocks() -> None:
    if have_command("luarocks"):
        _LOGGER.debug("'luarocks' is already installed")
        return
    _LOGGER.info("Installing 'luarocks'...")
    apt_install("luarocks")


def install_macchanger() -> None:
    if have_command("macchanger"):
        _LOGGER.debug("'macchanger' is already installed")
        return
    _LOGGER.info("Installing 'macchanger'...")
    apt_install("macchanger")


def install_neovim(*, config: Path | str | None = None) -> None:
    if have_command("nvim"):
        _LOGGER.debug("'neovim' is already installed")
    else:
        _LOGGER.info("Installing 'neovim'...")
        path_to = full_path("/usr/local/bin/nvim")
        with _yield_download(
            "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage"
        ) as appimage:
            _set_executable(appimage)
            run_commands(
                f"sudo mkdir -p {path_to.parent}", f"sudo mv {appimage} {path_to}"
            )
    if config is not None:
        config = full_path(config)
        if config.exists():
            symlink("~/.config/nvim", config)


def install_npm() -> None:
    # this is for neovim
    if have_command("npm"):
        _LOGGER.debug("'npm' is already installed")
        return
    _LOGGER.info("Installing 'npm'...")
    apt_install("nodejs", "npm")


def install_pre_commit() -> None:
    _uv_tool_install("pre-commit")


def install_pyright() -> None:
    _uv_tool_install("pyright")


def install_python3_13_venv() -> None:
    # this is for neovim
    if have_command("python3.13"):
        _LOGGER.debug(
            "'python3.13' is already installed (and presumably so is 'python3.13-venv'"
        )
        return
    _LOGGER.info("Installing 'python3.13-venv'...")
    apt_install("python3.13-venv")


def install_ripgrep(*, config: bool = False) -> None:
    if have_command("rg"):
        _LOGGER.debug("'ripgrep' is already installed")
    else:
        _LOGGER.info("Installing 'ripgrep'...")
        apt_install("ripgrep")
    if config:
        symlink("~/.config/ripgrep/ripgreprc", f"{_get_script_dir()}/ripgrep/ripgreprc")


def install_rsync() -> None:
    if have_command("rsync"):
        _LOGGER.debug("'rsync' is already installed")
        return
    _LOGGER.info("Installing 'rsync'...")
    apt_install("rsync")


def install_ruff() -> None:
    _uv_tool_install("ruff")


def install_shellcheck() -> None:
    if have_command("shellcheck"):
        _LOGGER.debug("'shellcheck' is already installed")
        return
    _LOGGER.info("Installing 'shellcheck'...")
    apt_install("shellcheck")


def install_shfmt() -> None:
    if have_command("shfmt"):
        _LOGGER.debug("'shfmt' is already installed")
        return
    _LOGGER.info("Installing 'shfmt'...")
    apt_install("shfmt")


def install_spotify() -> None:
    if have_command("spotify"):
        _LOGGER.debug("'spotify' is already installed")
        return
    install_curl()
    _LOGGER.info("Installing 'spotify'...")
    run_commands(
        "curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg",
        'echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list',
    )
    apt_install("spotify-client")


def install_starship(*, config: Path | str | None = None) -> None:
    if have_command("starship"):
        _LOGGER.debug("'starship' is already installed")
    else:
        _LOGGER.info("Installing 'starship'...")
        apt_install("starship")
    if config is not None:
        symlink("~/.config/starship.toml", config)


def install_stylua() -> None:
    if have_command("stylua"):
        _LOGGER.debug("'stylua' is already installed")
        return
    _LOGGER.info("Installing 'stylua'...")
    path_to = f"{_get_local_bin()}/stylua"
    with (
        _yield_github_latest_download(
            "johnnymorganz", "stylua", "stylua-linux-x86_64.zip"
        ) as zf,
        ZipFile(zf) as zfh,
        TemporaryDirectory() as temp_dir,
    ):
        zfh.extractall(temp_dir)
        (path_from,) = full_path(temp_dir).iterdir()
        _copyfile(path_from, path_to, executable=True)


def install_syncthing() -> None:
    if have_command("syncthing"):
        _LOGGER.debug("'syncthing' is already installed")
        return
    _LOGGER.info("Installing 'syncthing'...")
    apt_install("syncthing")


def install_tailscale() -> None:
    if have_command("tailscale"):
        _LOGGER.debug("'tailscale' is already installed")
        return
    _LOGGER.info("Installing 'tailscale'...")
    install_curl()
    run_commands("curl -fsSL https://tailscale.com/install.sh | sh")


def install_tmux() -> None:
    if have_command("tmux"):
        _LOGGER.debug("'tmux' is already installed")
    else:
        _LOGGER.info("Installing 'tmux'...")
        apt_install("tmux")
    _update_submodules()
    for filename_from, filename_to in [
        ("tmux.conf.local", "tmux.conf.local"),
        ("tmux.conf", ".tmux/.tmux.conf"),
    ]:
        symlink(
            f"~/.config/tmux/{filename_from}", f"{_get_script_dir()}/tmux/{filename_to}"
        )


def install_vim() -> None:
    if have_command("vim"):
        _LOGGER.debug("'vim' is already installed")
        return
    _LOGGER.info("Installing 'vim'...")
    apt_install("vim")


def install_wezterm() -> None:
    if have_command("wezterm"):
        _LOGGER.debug("'wezterm' is already installed")
    else:
        install_curl()
        _LOGGER.info("Installing 'wezterm'...")
        run_commands(
            "curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg",
            "echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list",
            "sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg",
        )
        apt_install("wezterm")
    symlink("~/.config/wezterm/wezterm.lua", f"{_get_script_dir()}/wezterm/wezterm.lua")


def install_yq() -> None:
    if have_command("yq"):
        _LOGGER.debug("'yq' is already installed")
        return
    _LOGGER.info("Installing 'yq'...")
    path_to = f"{_get_local_bin()}/yq"
    with _yield_github_latest_download("mikefarah", "yq", "yq_linux_amd64") as binary:
        _copyfile(binary, path_to, executable=True)


def install_zoom() -> None:
    if have_command("zoom"):
        _LOGGER.debug("'zoom' is already installed")
        return
    _LOGGER.info("Installing 'zoom'...")
    apt_install("libxcb-xinerama0", "libxcb-xtest0", "libxcb-cursor0")
    _dpkg_install("zoom_amd64.deb")


def install_zoxide() -> None:
    if have_command("zoxide"):
        _LOGGER.debug("'zoxide' is already installed")
        return
    _LOGGER.info("Installing 'zoxide'...")
    apt_install("zoxide")


def _setup_ssh_keys(ssh_keys: Path | str, /) -> None:
    if isinstance(ssh_keys, Path) or full_path(ssh_keys).is_file():
        _setup_ssh_keys_core(ssh_keys)
        return
    with _yield_download(ssh_keys) as temp_file:
        _setup_ssh_keys_core(temp_file)


def _setup_ssh_keys_core(path_from: Path | str, /) -> None:
    keys = [
        stripped
        for line in full_path(path_from).read_text().splitlines()
        if (stripped := line.strip()) != ""
    ]
    joined = "\n".join(keys)
    _ = full_path("~/.ssh/authorized_keys").write_text(joined)


def _setup_sshd() -> None:
    path = full_path("/etc/ssh/sshd_config")
    for from_, to in [
        ("#PermitRootLogin prohibit-password", "PermitRootLogin no"),
        ("#PubkeyAuthentication yes", "PubkeyAuthentication yes"),
        ("#PasswordAuthentication yes", "PasswordAuthentication no"),
    ]:
        _replace_line(path, from_, to)


# utilities


# main


def _setup_mac(settings: _Settings, /) -> None:
    install_uv()

    if settings.bump_my_version:
        install_bump_my_version()  # after uv
    if settings.pre_commit:
        install_pre_commit()  # after uv
    if settings.pyright:
        install_pyright()  # after uv
    if settings.ruff:
        install_ruff()  # after uv


def _setup_debian(settings: _Settings, /) -> None:
    install_neovim(config=f"{_get_script_dir()}/nvim")
    install_npm()
    install_python3_13_venv()
    install_starship(config=f"{_get_script_dir()}/starship/starship.toml")
    _setup_sshd()
    if settings.age:
        install_age()
    if settings.bat:
        install_bat()
    if settings.bottom:
        install_bottom(config=True)
    if settings.build_essential:
        install_build_essential()
    if settings.caffeine:
        install_caffeine()
    if settings.direnv:
        install_direnv(
            direnv_toml=f"{_get_script_dir()}/direnv/direnv.toml",
            direnvrc=f"{_get_script_dir()}/direnv/direnvrc",
        )
    if settings.dust:
        install_dust()
    if settings.eza:
        install_eza()
    if settings.fd_find:
        install_fd_find(config=True)
    if settings.fzf:
        install_fzf(fzf_fish=True)
    if settings.gh:
        install_gh()
    if settings.glab:
        install_glab()
    if settings.just:
        install_just()
    if settings.jq:
        install_jq()
    if settings.luarocks:
        install_luarocks()
    if settings.macchanger:
        install_macchanger()
    if settings.ripgrep:
        install_ripgrep(config=True)
    if settings.rsync:
        install_rsync()
    if settings.shellcheck:
        install_shellcheck()
    if settings.shfmt:
        install_shfmt()
    if settings.sops:
        install_sops(age="~/secrets/age/age-secret-key.txt")
    if settings.ssh_keys is not None:
        _setup_ssh_keys(settings.ssh_keys)
    if settings.stylua:
        install_stylua()
    if settings.syncthing:
        install_syncthing()
    if settings.tmux:
        install_tmux()
    if settings.vim:
        install_vim()
    if settings.yq:
        install_yq()
    if settings.zoom:
        install_zoom()
    if settings.zoxide:
        install_zoxide()

    install_uv()  # after curl
    if settings.docker:
        install_docker()  # after curl
    if settings.spotify:
        install_spotify()  # after curl
    if settings.tailscale:
        install_tailscale()  # after curl
    if settings.wezterm:
        install_wezterm()  # after curl

    if settings.luacheck:
        install_luacheck()  # after luarocks

    if settings.bump_my_version:
        install_bump_my_version()  # after uv
    if settings.pre_commit:
        install_pre_commit()  # after uv
    if settings.pyright:
        install_pyright()  # after uv
    if settings.ruff:
        install_ruff()  # after uv


main(_Settings.parse())

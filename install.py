#!/usr/bin/env python3
from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from dataclasses import dataclass
from logging import getLogger
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import assert_never
from zipfile import ZipFile

# constants


_LOGGER = getLogger(__name__)


# environments


@dataclass(order=True, unsafe_hash=True, kw_only=True)
class _Settings:
    age: bool
    bat: bool
    bottom: bool
    build_essential: bool
    bump_my_version: bool
    caffeine: bool
    delta: bool
    direnv: bool
    docker: bool
    dust: bool
    eza: bool
    fd_find: bool
    fzf: bool
    gh: bool
    glab: bool
    jq: bool
    just: bool
    luacheck: bool
    luarocks: bool
    macchanger: bool
    pre_commit: bool
    pyright: bool
    ripgrep: bool
    ruff: bool
    rsync: bool
    shellcheck: bool
    shfmt: bool
    sops: bool
    spotify: bool
    ssh_keys: str | None
    stylua: bool
    syncthing: bool
    tailscale: bool
    tmux: bool
    verbose: bool
    vim: bool
    wezterm: bool
    yq: bool
    zoom: bool
    zoxide: bool

    @classmethod
    def parse(cls) -> "_Settings":
        parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
        _ = parser.add_argument(
            "-a", "--age", action="store_true", help="Install 'age'."
        )
        _ = parser.add_argument(
            "-ba", "--bat", action="store_true", help="Install 'bat'."
        )
        _ = parser.add_argument(
            "-bt", "--bottom", action="store_true", help="Install 'bottom'."
        )
        _ = parser.add_argument(
            "-be",
            "--build-essential",
            action="store_true",
            help="Install 'build-essential'.",
        )
        _ = parser.add_argument(
            "-bu",
            "--bump-my-version",
            action="store_true",
            help="Install 'bump-my-version'.",
        )
        _ = parser.add_argument(
            "-c", "--caffeine", action="store_true", help="Install 'caffeine'."
        )
        _ = parser.add_argument(
            "-de", "--delta", action="store_true", help="Install 'delta'."
        )
        _ = parser.add_argument(
            "-di", "--direnv", action="store_true", help="Install 'direnv'."
        )
        _ = parser.add_argument(
            "-do", "--docker", action="store_true", help="Install 'docker'."
        )
        _ = parser.add_argument(
            "-du", "--dust", action="store_true", help="Install 'dust'."
        )
        _ = parser.add_argument(
            "-e", "--eza", action="store_true", help="Install 'eza'."
        )
        _ = parser.add_argument(
            "-fd", "--fd-find", action="store_true", help="Install 'fd-find'."
        )
        _ = parser.add_argument(
            "-fz", "--fzf", action="store_true", help="Install 'fzf'."
        )
        _ = parser.add_argument(
            "-gh", "--gh", action="store_true", help="Install 'gh'."
        )
        _ = parser.add_argument(
            "-gl", "--glab", action="store_true", help="Install 'glab'."
        )
        _ = parser.add_argument(
            "-jq", "--jq", action="store_true", help="Install 'jq'."
        )
        _ = parser.add_argument(
            "-ju", "--just", action="store_true", help="Install 'just'."
        )
        _ = parser.add_argument(
            "-lc", "--luacheck", action="store_true", help="Install 'luacheck'."
        )
        _ = parser.add_argument(
            "-lr", "--luarocks", action="store_true", help="Install 'luarocks'."
        )
        _ = parser.add_argument(
            "-m", "--macchanger", action="store_true", help="Install 'macchanger'."
        )
        _ = parser.add_argument(
            "-pr", "--pre-commit", action="store_true", help="Install 'pre-commit'."
        )
        _ = parser.add_argument(
            "-py", "--pyright", action="store_true", help="Install 'pyright'."
        )
        _ = parser.add_argument(
            "-ri", "--ripgrep", action="store_true", help="Install 'ripgrep'."
        )
        _ = parser.add_argument(
            "-ru", "--ruff", action="store_true", help="Install 'ruff'."
        )
        _ = parser.add_argument(
            "-rs", "--rsync", action="store_true", help="Install 'rsync'."
        )
        _ = parser.add_argument(
            "-sc", "--shellcheck", action="store_true", help="Install 'shellcheck'."
        )
        _ = parser.add_argument(
            "-sf", "--shfmt", action="store_true", help="Install 'shfmt'."
        )
        _ = parser.add_argument(
            "-so", "--sops", action="store_true", help="Install 'sops'."
        )
        _ = parser.add_argument(
            "-sp", "--spotify", action="store_true", help="Install 'spotify'."
        )
        _ = parser.add_argument(
            "-ss",
            "--ssh-keys",
            default=None,
            type=str,
            help="Install 'ssh-keys' from a file or URL.",
        )
        _ = parser.add_argument(
            "-st", "--stylua", action="store_true", help="Install 'stylua'."
        )
        _ = parser.add_argument(
            "-sy", "--syncthing", action="store_true", help="Install 'syncthing'."
        )
        _ = parser.add_argument(
            "-ta", "--tailscale", action="store_true", help="Install 'tailscale'."
        )
        _ = parser.add_argument(
            "-tm", "--tmux", action="store_true", help="Install 'tmux'."
        )
        _ = parser.add_argument(
            "-vi", "--vim", action="store_true", help="Install 'vim'."
        )
        _ = parser.add_argument(
            "-yq", "--yq", action="store_true", help="Install 'yq'."
        )
        _ = parser.add_argument(
            "-w", "--wezterm", action="store_true", help="Install 'wezterm'."
        )
        _ = parser.add_argument(
            "-zm", "--zoom", action="store_true", help="Install 'zoom'."
        )
        _ = parser.add_argument(
            "-zx", "--zoxide", action="store_true", help="Install 'zoxide'."
        )
        _ = parser.add_argument(
            "-ve", "--verbose", action="store_true", help="Verbose mode."
        )
        return _Settings(**vars(parser.parse_args()))


# library


def install_age() -> None:
    if _have_command("age"):
        _LOGGER.debug("'age' is already installed")
        return
    _LOGGER.info("Installing 'age'...")
    _apt_install("age")


def install_bat() -> None:
    if _have_command("batcat"):
        _LOGGER.debug("'bat' is already installed")
    else:
        _LOGGER.info("Installing 'bat'...")
        _apt_install("bat")
    symlink("~/.local/bin/bat", "/usr/bin/batcat")


def install_bottom(*, config: bool = False) -> None:
    if _have_command("btm"):
        _LOGGER.debug("'btm' is already installed")
    else:
        _LOGGER.info("Installing 'bottom'...")
        with _yield_github_latest_download(
            "ClementTsang", "bottom", "bottom_${tag}-1_amd64.deb"
        ) as path:
            _dpkg_install(path)
    if config:
        symlink(
            "~/.config/bottom/bottom.toml", f"{_get_script_dir()}/bottom/bottom.toml"
        )


def install_brew() -> None:
    if _have_command("brew"):
        _LOGGER.debug("'brew' is already installed")
        return
    _LOGGER.info("Installing 'brew'...")
    _run_commands(
        'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    )


def install_build_essential() -> None:
    if _have_command("cc"):
        _LOGGER.debug(
            "'cc' is already installed (and presumably so is 'build-essential'"
        )
        return
    _LOGGER.info("Installing 'build-essential'...")
    _apt_install("build-essential")


def install_bump_my_version() -> None:
    _uv_tool_install("bump-my-version")


def install_caffeine() -> None:
    if _have_command("caffeine"):
        _LOGGER.debug("'caffeine' is already installed")
        return
    _LOGGER.info("Installing 'caffeine'...")
    _apt_install("caffeine")


def install_curl() -> None:
    if _have_command("curl"):
        _LOGGER.debug("'curl' is already installed")
        return
    _LOGGER.info("Installing 'curl'...")
    _apt_install("curl")


def install_delta() -> None:
    if _have_command("delta"):
        _LOGGER.debug("'delta' is already installed")
        return
    _LOGGER.info("Installing 'delta'...")
    _apt_install("git-delta")


def install_direnv(
    *, direnv_toml: Path | str | None = None, direnvrc: Path | str | None = None
) -> None:
    if _have_command("direnv"):
        _LOGGER.debug("'direnv' is already installed")
    else:
        _LOGGER.info("Installing 'direnv'...")
        _apt_install("direnv")
    for path_to in [direnv_toml, direnvrc]:
        if path_to is not None:
            name = to_path(path_to).name
            symlink(f"~/.config/direnv/{name}", path_to)


def install_docker() -> None:
    if _have_command("docker"):
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
    _run_commands(*(f"sudo apt-get remove {p}" for p in packages))
    _apt_install("ca-certificates", "curl")
    _run_commands(
        "sudo install -m 0755 -d /etc/apt/keyrings",
        "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",
        "sudo chmod a+r /etc/apt/keyrings/docker.asc",
        'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null',
    )
    _apt_install(
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin",
    )
    _run_commands("sudo usermod -aG docker $USER")


def install_dust() -> None:
    if _have_command("dust"):
        _LOGGER.debug("'dust' is already installed")
        return
    _LOGGER.info("Installing 'dust'...")
    _apt_install("du-dust")


def install_eza() -> None:
    if _have_command("eza"):
        _LOGGER.debug("'eza' is already installed")
        return
    _LOGGER.info("Installing 'eza'...")
    _apt_install("eza")


def install_fd_find(*, config: bool = False) -> None:
    if _have_command("fdfind"):
        _LOGGER.debug("'fd-find' is already installed")
    else:
        _LOGGER.info("Installing 'fd-find'...")
        _apt_install("fd-find")
    if config:
        symlink("~/.config/fd/ignore", f"{_get_script_dir()}/fd/ignore")


def install_fzf(*, fzf_fish: bool = False) -> None:
    if _have_command("fzf"):
        _LOGGER.debug("'fzf' is already installed")
    else:
        _LOGGER.info("Installing 'fzf'...")
        match _System.identify():
            case _System.mac:
                _brew_install("fzf")
            case _System.linux:
                _apt_install("fzf")
            case never:
                assert_never(never)
    if fzf_fish:
        for path in to_path(f"{_get_local_bin()}/fzf/fzf.fish/functions").iterdir():
            _copyfile(path, f"~/.config/fish/functions/{path.name}")


def install_gh() -> None:
    if _have_command("gh"):
        _LOGGER.debug("'gh' is already installed")
        return
    _LOGGER.info("Installing 'gh'...")
    _apt_install("gh")


def install_glab() -> None:
    if _have_command("glab"):
        _LOGGER.debug("'glab' is already installed")
    else:
        _LOGGER.info("Installing 'glab'...")
        _apt_install("glab")
    path_to = to_path("~/work/infra/gitlab/cli.yml")
    if path_to.exists():
        symlink("~/.config/glab-cli/config.yml", path_to)


def install_jq() -> None:
    if _have_command("jq"):
        _LOGGER.debug("'jq' is already installed")
        return
    _LOGGER.info("Installing 'jq'...")
    _apt_install("jq")


def install_just() -> None:
    if _have_command("just"):
        _LOGGER.debug("'just' is already installed")
        return
    _LOGGER.info("Installing 'just'...")
    _apt_install("just")


def install_luacheck() -> None:
    if _have_command("luacheck"):
        _LOGGER.debug("'luacheck' is already installed")
        return
    install_luarocks()
    _LOGGER.info("Installing 'luacheck'...")
    _luarocks_install("luacheck")


def install_luarocks() -> None:
    if _have_command("luarocks"):
        _LOGGER.debug("'luarocks' is already installed")
        return
    _LOGGER.info("Installing 'luarocks'...")
    _apt_install("luarocks")


def install_macchanger() -> None:
    if _have_command("macchanger"):
        _LOGGER.debug("'macchanger' is already installed")
        return
    _LOGGER.info("Installing 'macchanger'...")
    _apt_install("macchanger")


def install_neovim(*, config: Path | str | None = None) -> None:
    if _have_command("nvim"):
        _LOGGER.debug("'neovim' is already installed")
    else:
        _LOGGER.info("Installing 'neovim'...")
        path_to = to_path("/usr/local/bin/nvim")
        with _yield_download(
            "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage"
        ) as appimage:
            _set_executable(appimage)
            _run_commands(
                f"sudo mkdir -p {path_to.parent}", f"sudo mv {appimage} {path_to}"
            )
    if config is not None:
        config = to_path(config)
        if config.exists():
            symlink("~/.config/nvim", config)


def install_npm() -> None:
    # this is for neovim
    if _have_command("npm"):
        _LOGGER.debug("'npm' is already installed")
        return
    _LOGGER.info("Installing 'npm'...")
    _apt_install("nodejs", "npm")


def install_pre_commit() -> None:
    _uv_tool_install("pre-commit")


def install_pyright() -> None:
    _uv_tool_install("pyright")


def install_python3_13_venv() -> None:
    # this is for neovim
    if _have_command("python3.13"):
        _LOGGER.debug(
            "'python3.13' is already installed (and presumably so is 'python3.13-venv'"
        )
        return
    _LOGGER.info("Installing 'python3.13-venv'...")
    _apt_install("python3.13-venv")


def install_ripgrep(*, config: bool = False) -> None:
    if _have_command("rg"):
        _LOGGER.debug("'ripgrep' is already installed")
    else:
        _LOGGER.info("Installing 'ripgrep'...")
        _apt_install("ripgrep")
    if config:
        symlink("~/.config/ripgrep/ripgreprc", f"{_get_script_dir()}/ripgrep/ripgreprc")


def install_rsync() -> None:
    if _have_command("rsync"):
        _LOGGER.debug("'rsync' is already installed")
        return
    _LOGGER.info("Installing 'rsync'...")
    _apt_install("rsync")


def install_ruff() -> None:
    _uv_tool_install("ruff")


def install_shellcheck() -> None:
    if _have_command("shellcheck"):
        _LOGGER.debug("'shellcheck' is already installed")
        return
    _LOGGER.info("Installing 'shellcheck'...")
    _apt_install("shellcheck")


def install_shfmt() -> None:
    if _have_command("shfmt"):
        _LOGGER.debug("'shfmt' is already installed")
        return
    _LOGGER.info("Installing 'shfmt'...")
    _apt_install("shfmt")


def install_sops(*, age: Path | str | None = None) -> None:
    if _have_command("sops"):
        _LOGGER.debug("'sops' is already installed")
    else:
        _LOGGER.info("Installing 'sops'...")
        path_to = f"{_get_local_bin()}/sops"
        with _yield_github_latest_download(
            "getsops", "sops", "sops-${tag}.linux.amd64"
        ) as binary:
            _copyfile(binary, path_to, executable=True)
    if age is not None:
        age = to_path(age)
        if age.exists():
            symlink("~/.config/sops/age/keys.txt", age)
        else:
            _LOGGER.warning("Unable to find age secret key %r", str(age))


def install_spotify() -> None:
    if _have_command("spotify"):
        _LOGGER.debug("'spotify' is already installed")
        return
    install_curl()
    _LOGGER.info("Installing 'spotify'...")
    _run_commands(
        "curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg",
        'echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list',
    )
    _apt_install("spotify-client")


def install_starship(*, config: Path | str | None = None) -> None:
    if _have_command("starship"):
        _LOGGER.debug("'starship' is already installed")
    else:
        _LOGGER.info("Installing 'starship'...")
        _apt_install("starship")
    if config is not None:
        symlink("~/.config/starship.toml", config)


def install_stylua() -> None:
    if _have_command("stylua"):
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
        (path_from,) = to_path(temp_dir).iterdir()
        _copyfile(path_from, path_to, executable=True)


def install_syncthing() -> None:
    if _have_command("syncthing"):
        _LOGGER.debug("'syncthing' is already installed")
        return
    _LOGGER.info("Installing 'syncthing'...")
    _apt_install("syncthing")


def install_tailscale() -> None:
    if _have_command("tailscale"):
        _LOGGER.debug("'tailscale' is already installed")
        return
    _LOGGER.info("Installing 'tailscale'...")
    install_curl()
    _run_commands("curl -fsSL https://tailscale.com/install.sh | sh")


def install_tmux() -> None:
    if _have_command("tmux"):
        _LOGGER.debug("'tmux' is already installed")
    else:
        _LOGGER.info("Installing 'tmux'...")
        _apt_install("tmux")
    _update_submodules()
    for filename_from, filename_to in [
        ("tmux.conf.local", "tmux.conf.local"),
        ("tmux.conf", ".tmux/.tmux.conf"),
    ]:
        symlink(
            f"~/.config/tmux/{filename_from}", f"{_get_script_dir()}/tmux/{filename_to}"
        )


def install_uv() -> None:
    if _have_command("uv"):
        _LOGGER.debug("'uv' is already installed")
        return
    install_curl()
    _LOGGER.info("Installing 'uv'...")
    _run_commands("curl -LsSf https://astral.sh/uv/install.sh | sh")


def install_vim() -> None:
    if _have_command("vim"):
        _LOGGER.debug("'vim' is already installed")
        return
    _LOGGER.info("Installing 'vim'...")
    _apt_install("vim")


def install_wezterm() -> None:
    if _have_command("wezterm"):
        _LOGGER.debug("'wezterm' is already installed")
    else:
        install_curl()
        _LOGGER.info("Installing 'wezterm'...")
        _run_commands(
            "curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg",
            "echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list",
            "sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg",
        )
        _apt_install("wezterm")
    symlink("~/.config/wezterm/wezterm.lua", f"{_get_script_dir()}/wezterm/wezterm.lua")


def install_yq() -> None:
    if _have_command("yq"):
        _LOGGER.debug("'yq' is already installed")
        return
    _LOGGER.info("Installing 'yq'...")
    path_to = f"{_get_local_bin()}/yq"
    with _yield_github_latest_download("mikefarah", "yq", "yq_linux_amd64") as binary:
        _copyfile(binary, path_to, executable=True)


def install_zoom() -> None:
    if _have_command("zoom"):
        _LOGGER.debug("'zoom' is already installed")
        return
    _LOGGER.info("Installing 'zoom'...")
    _apt_install("libxcb-xinerama0", "libxcb-xtest0", "libxcb-cursor0")
    _dpkg_install("zoom_amd64.deb")


def install_zoxide() -> None:
    if _have_command("zoxide"):
        _LOGGER.debug("'zoxide' is already installed")
        return
    _LOGGER.info("Installing 'zoxide'...")
    _apt_install("zoxide")


def _setup_bash() -> None:
    symlink("~/.bashrc", f"{_get_script_dir()}/bash/bashrc")


def _setup_pdb() -> None:
    symlink("~/.pdbrc", f"{_get_script_dir()}/pdb/pdbrc")


def _setup_psql() -> None:
    symlink("~/.psqlrc", f"{_get_script_dir()}/psql/psqlrc")


def _setup_zsh() -> None:
    symlink("~/.zshrc", f"{_get_script_dir()}/zsh/zshrc")


def _setup_ssh_keys(ssh_keys: Path | str, /) -> None:
    if isinstance(ssh_keys, Path) or to_path(ssh_keys).is_file():
        _setup_ssh_keys_core(ssh_keys)
        return
    with _yield_download(ssh_keys) as temp_file:
        _setup_ssh_keys_core(temp_file)


def _setup_ssh_keys_core(path_from: Path | str, /) -> None:
    keys = [
        stripped
        for line in to_path(path_from).read_text().splitlines()
        if (stripped := line.strip()) != ""
    ]
    joined = "\n".join(keys)
    _ = to_path("~/.ssh/authorized_keys").write_text(joined)


def _setup_sshd() -> None:
    path = to_path("/etc/ssh/sshd_config")
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

    install_fish()  # after brew
    if settings.fzf:
        install_fzf(fzf_fish=True)  # after brew

    if settings.bump_my_version:
        install_bump_my_version()  # after uv
    if settings.pre_commit:
        install_pre_commit()  # after uv
    if settings.pyright:
        install_pyright()  # after uv
    if settings.ruff:
        install_ruff()  # after uv


def _setup_debian(settings: _Settings, /) -> None:
    install_curl()
    install_fish()
    install_git(config=True)
    install_neovim(config=f"{_get_script_dir()}/nvim")
    install_npm()
    install_python3_13_venv()
    install_starship(config=f"{_get_script_dir()}/starship/starship.toml")
    _setup_bash()
    _setup_pdb()
    _setup_psql()
    _setup_sshd()
    _setup_zsh()
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
    if settings.delta:
        install_delta()
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

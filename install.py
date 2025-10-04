#!/usr/bin/env python3
# ruff: noqa: E501, S310, S602
from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass
from logging import basicConfig, getLogger
from os import environ, geteuid
from pathlib import Path
from re import search
from shutil import copyfile, which
from stat import S_IXUSR
from string import Template
from subprocess import check_call, check_output
from tempfile import TemporaryDirectory
from urllib.parse import urlparse
from urllib.request import urlopen
from zipfile import ZipFile

# constants


_LOGGER = getLogger(__name__)


# settings


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
            "-v", "--verbose", action="store_true", help="Verbose mode."
        )
        return _Settings(**vars(parser.parse_args()))


# library


def _install_age() -> None:
    if _have_command("age"):
        _LOGGER.debug("'age' is already installed")
        return
    _LOGGER.info("Installing 'age'...")
    _apt_install("age")


def _install_bat() -> None:
    if _have_command("batcat"):
        _LOGGER.debug("'bat' is already installed")
        return
    _LOGGER.info("Installing 'bat'...")
    _apt_install("bat")


def _install_bottom(*, config: bool = False) -> None:
    if _have_command("btm"):
        _LOGGER.debug("'btm' is already installed")
    else:
        _LOGGER.info("Installing 'bottom'...")
        with _yield_github_latest_download(
            "ClementTsang", "bottom", "bottom_${tag}-1_amd64.deb"
        ) as path:
            _dpkg_install(path)
    if config:
        _setup_symlink(
            "~/.config/bottom/bottom.toml", f"{_get_script_dir()}/bottom/bottom.toml"
        )


def _install_build_essential() -> None:
    if _have_command("cc"):
        _LOGGER.debug(
            "'cc' is already installed (and presumably so is 'build-essential'"
        )
        return
    _LOGGER.info("Installing 'build-essential'...")
    _apt_install("build-essential")


def _install_bump_my_version() -> None:
    _uv_tool_install("bump-my-version")


def _install_caffeine() -> None:
    if _have_command("caffeine"):
        _LOGGER.debug("'caffeine' is already installed")
        return
    _LOGGER.info("Installing 'caffeine'...")
    _apt_install("caffeine")


def _install_curl() -> None:
    if _have_command("curl"):
        _LOGGER.debug("'curl' is already installed")
        return
    _LOGGER.info("Installing 'curl'...")
    _apt_install("curl")


def _install_delta() -> None:
    if _have_command("delta"):
        _LOGGER.debug("'delta' is already installed")
        return
    _LOGGER.info("Installing 'delta'...")
    _apt_install("git-delta")


def _install_direnv(*, config: bool = False) -> None:
    if _have_command("direnv"):
        _LOGGER.debug("'direnv' is already installed")
    else:
        _LOGGER.info("Installing 'direnv'...")
        _apt_install("direnv")
    if config:
        for filename in ["direnv.toml", "direnvrc"]:
            _setup_symlink(
                f"~/.config/direnv/{filename}", f"{_get_script_dir()}/direnv/{filename}"
            )


def _install_docker() -> None:
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


def _install_dust() -> None:
    if _have_command("dust"):
        _LOGGER.debug("'dust' is already installed")
        return
    _LOGGER.info("Installing 'dust'...")
    _apt_install("du-dust")


def _install_eza() -> None:
    if _have_command("eza"):
        _LOGGER.debug("'eza' is already installed")
        return
    _LOGGER.info("Installing 'eza'...")
    _apt_install("eza")


def _install_fd_find(*, config: bool = False) -> None:
    if _have_command("fdfind"):
        _LOGGER.debug("'fd-find' is already installed")
    else:
        _LOGGER.info("Installing 'fd-find'...")
        _apt_install("fd-find")
    if config:
        _setup_symlink("~/.config/fd/ignore", f"{_get_script_dir()}/fd/ignore")


def _install_fish() -> None:
    if _have_command("fish"):
        _LOGGER.debug("'fish' is already installed")
    else:
        _LOGGER.info("Installing 'fish'...")
        _run_commands(
            """echo 'deb http://download.opensuse.org/repositories/shells:/fish/Debian_13/ /' | sudo tee /etc/apt/sources.list.d/shells:fish.list""",
            """curl -fsSL https://download.opensuse.org/repositories/shells:fish/Debian_13/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish.gpg > /dev/null""",
        )
        _apt_install("fish")
    if search(r"/fish$", environ["SHELL"]):
        _LOGGER.debug("'fish' is already the default shell")
    else:
        _LOGGER.info("Setting 'fish' to be the default shell")
        _ = _run_commands("sudo chsh -s $(which fish)")
    for filename_from, filename_to in [
        ("config.fish", "config.fish"),
        ("conf.d/0-env.fish", "env.fish"),
        ("conf.d/git.fish", "git.fish"),
        ("conf.d/work.fish", "work.fish"),
    ]:
        _setup_symlink(
            f"~/.config/fish/{filename_from}", f"{_get_script_dir()}/fish/{filename_to}"
        )


def _install_fzf(*, fzf_fish: bool = False) -> None:
    if _have_command("fzf"):
        _LOGGER.debug("'fzf' is already installed")
    else:
        _LOGGER.info("Installing 'fzf'...")
        _apt_install("fzf")
    if fzf_fish:
        for path in (
            _get_script_dir().joinpath("fzf", "fzf.fish", "functions").iterdir()
        ):
            _copyfile(path, f"~/.config/fish/functions/{path.name}")


def _install_git(*, config: bool = False) -> None:
    if _have_command("git"):
        _LOGGER.debug("'git' is already installed")
    else:
        _LOGGER.info("Installing 'git'...")
        _apt_install("git")
    if config:
        for filename in ["config", "ignore"]:
            _setup_symlink(
                f"~/.config/git/{filename}", f"{_get_script_dir()}/git/{filename}"
            )


def _install_gh() -> None:
    if _have_command("gh"):
        _LOGGER.debug("'gh' is already installed")
        return
    _LOGGER.info("Installing 'gh'...")
    _apt_install("gh")


def _install_glab() -> None:
    if _have_command("glab"):
        _LOGGER.debug("'glab' is already installed")
    else:
        _LOGGER.info("Installing 'glab'...")
        _apt_install("glab")
    path_to = _to_path("~/work/infra/gitlab/cli.yml")
    if path_to.exists():
        _setup_symlink("~/.config/glab-cli/config.yml", path_to)


def _install_jq() -> None:
    if _have_command("jq"):
        _LOGGER.debug("'jq' is already installed")
        return
    _LOGGER.info("Installing 'jq'...")
    _apt_install("jq")


def _install_just() -> None:
    if _have_command("just"):
        _LOGGER.debug("'just' is already installed")
        return
    _LOGGER.info("Installing 'just'...")
    _apt_install("just")


def _install_luacheck() -> None:
    if _have_command("luacheck"):
        _LOGGER.debug("'luacheck' is already installed")
        return
    _install_luarocks()
    _LOGGER.info("Installing 'luacheck'...")
    _luarocks_install("luacheck")


def _install_luarocks() -> None:
    if _have_command("luarocks"):
        _LOGGER.debug("'luarocks' is already installed")
        return
    _LOGGER.info("Installing 'luarocks'...")
    _apt_install("luarocks")


def _install_macchanger() -> None:
    if _have_command("macchanger"):
        _LOGGER.debug("'macchanger' is already installed")
        return
    _LOGGER.info("Installing 'macchanger'...")
    _apt_install("macchanger")


def _install_neovim(*, path_config: Path | str | None = None) -> None:
    if _have_command("nvim"):
        _LOGGER.debug("'neovim' is already installed")
    else:
        _LOGGER.info("Installing 'neovim'...")
        path_to = _to_path("/usr/local/bin/nvim")
        with _yield_download(
            "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage"
        ) as appimage:
            _set_executable(appimage)
            _run_commands(f"sudo mv {appimage} {path_to}")
    if path_config is not None:
        path_config = _to_path(path_config)
        if path_config.exists():
            _setup_symlink("~/.config/nvim", path_config)


def _install_npm() -> None:
    # this is for neovim
    if _have_command("npm"):
        _LOGGER.debug("'npm' is already installed")
        return
    _LOGGER.info("Installing 'npm'...")
    _apt_install("nodejs", "npm")


def _install_pre_commit() -> None:
    _uv_tool_install("pre-commit")


def _install_pyright() -> None:
    _uv_tool_install("pyright")


def _install_python3_13_venv() -> None:
    # this is for neovim
    if _have_command("python3.13"):
        _LOGGER.debug(
            "'python3.13' is already installed (and presumably so is 'python3.13-venv'"
        )
        return
    _LOGGER.info("Installing 'python3.13-venv'...")
    _apt_install("python3.13-venv")


def _install_ripgrep(*, config: bool = False) -> None:
    if _have_command("rg"):
        _LOGGER.debug("'ripgrep' is already installed")
    else:
        _LOGGER.info("Installing 'ripgrep'...")
        _apt_install("ripgrep")
    if config:
        _setup_symlink(
            "~/.config/ripgrep/ripgreprc", f"{_get_script_dir()}/ripgrep/ripgreprc"
        )


def _install_rsync() -> None:
    if _have_command("rsync"):
        _LOGGER.debug("'rsync' is already installed")
        return
    _LOGGER.info("Installing 'rsync'...")
    _apt_install("rsync")


def _install_ruff() -> None:
    _uv_tool_install("ruff")


def _install_shellcheck() -> None:
    if _have_command("shellcheck"):
        _LOGGER.debug("'shellcheck' is already installed")
        return
    _LOGGER.info("Installing 'shellcheck'...")
    _apt_install("shellcheck")


def _install_shfmt() -> None:
    if _have_command("shfmt"):
        _LOGGER.debug("'shfmt' is already installed")
        return
    _LOGGER.info("Installing 'shfmt'...")
    _apt_install("shfmt")


def _install_sops(*, path_age: Path | str | None = None) -> None:
    if _have_command("sops"):
        _LOGGER.debug("'sops' is already installed")
    else:
        _LOGGER.info("Installing 'sops'...")
        path_to = _get_local_bin().joinpath("sops")
        with _yield_github_latest_download(
            "getsops", "sops", "sops-${tag}.linux.amd64"
        ) as binary:
            _copyfile(binary, path_to, executable=True)
    if path_age is not None:
        path_age = _to_path(path_age)
        if path_age.exists():
            _setup_symlink("~/.config/sops/age/keys.txt", path_age)


def _install_spotify() -> None:
    if _have_command("spotify"):
        _LOGGER.debug("'spotify' is already installed")
        return
    _install_curl()
    _LOGGER.info("Installing 'spotify'...")
    _run_commands(
        "curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg",
        'echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list',
    )
    _apt_install("spotify-client")


def _install_starship(*, config: bool = False) -> None:
    if _have_command("starship"):
        _LOGGER.debug("'starship' is already installed")
    else:
        _LOGGER.info("Installing 'starship'...")
        _apt_install("starship")
    if config:
        _setup_symlink(
            "~/.config/starship.toml", f"{_get_script_dir()}/starship/starship.toml"
        )


def _install_stylua() -> None:
    if _have_command("stylua"):
        _LOGGER.debug("'stylua' is already installed")
        return
    _LOGGER.info("Installing 'stylua'...")
    path_to = _get_local_bin().joinpath("stylua")
    with (
        _yield_github_latest_download(
            "johnnymorganz", "stylua", "stylua-linux-x86_64.zip"
        ) as zf,
        ZipFile(zf) as zfh,
        TemporaryDirectory() as temp_dir,
    ):
        zfh.extractall(temp_dir)
        (path_from,) = _to_path(temp_dir).iterdir()
        _copyfile(path_from, path_to, executable=True)


def _install_syncthing() -> None:
    if _have_command("syncthing"):
        _LOGGER.debug("'syncthing' is already installed")
        return
    _LOGGER.info("Installing 'syncthing'...")
    _apt_install("syncthing")


def _install_tailscale() -> None:
    if _have_command("tailscale"):
        _LOGGER.debug("'tailscale' is already installed")
        return
    _LOGGER.info("Installing 'tailscale'...")
    _install_curl()
    _run_commands("curl -fsSL https://tailscale.com/install.sh | sh")


def _install_tmux() -> None:
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
        _setup_symlink(
            f"~/.config/tmux/{filename_from}", f"{_get_script_dir()}/tmux/{filename_to}"
        )


def _install_uv() -> None:
    if _have_command("uv"):
        _LOGGER.debug("'uv' is already installed")
        return
    _install_curl()
    _LOGGER.info("Installing 'uv'...")
    _run_commands("curl -LsSf https://astral.sh/uv/install.sh | sh")


def _install_wezterm() -> None:
    if _have_command("wezterm"):
        _LOGGER.debug("'wezterm' is already installed")
    else:
        _install_curl()
        _LOGGER.info("Installing 'wezterm'...")
        _run_commands(
            "curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg",
            "echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list",
            "sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg",
        )
        _apt_install("wezterm")
    _setup_symlink(
        "~/.config/wezterm/wezterm.lua", f"{_get_script_dir()}/wezterm/wezterm.lua"
    )


def _install_yq() -> None:
    if _have_command("yq"):
        _LOGGER.debug("'yq' is already installed")
        return
    _LOGGER.info("Installing 'yq'...")
    _apt_install("yq")


def _install_zoom() -> None:
    if _have_command("zoom"):
        _LOGGER.debug("'zoom' is already installed")
        return
    _LOGGER.info("Installing 'zoom'...")
    _apt_install("libxcb-xinerama0", "libxcb-xtest0", "libxcb-cursor0")
    _dpkg_install("zoom_amd64.deb")


def _install_zoxide() -> None:
    if _have_command("zoxide"):
        _LOGGER.debug("'zoxide' is already installed")
        return
    _LOGGER.info("Installing 'zoxide'...")
    _apt_install("zoxide")


def _setup_bash() -> None:
    _setup_symlink("~/.bashrc", f"{_get_script_dir()}/bash/bashrc")


def _setup_pdb() -> None:
    _setup_symlink("~/.pdbrc", f"{_get_script_dir()}/pdb/pdbrc")


def _setup_psql() -> None:
    _setup_symlink("~/.psqlrc", f"{_get_script_dir()}/psql/psqlrc")


def _setup_zsh() -> None:
    _setup_symlink("~/.zshrc", f"{_get_script_dir()}/zsh/zshrc")


def _setup_ssh_keys(ssh_keys: Path | str, /) -> None:
    if isinstance(ssh_keys, Path) or _to_path(ssh_keys).is_file():
        _setup_ssh_keys_core(ssh_keys)
        return
    with _yield_download(ssh_keys) as temp_file:
        _setup_ssh_keys_core(temp_file)


def _setup_ssh_keys_core(path_from: Path | str, /) -> None:
    keys = [
        stripped
        for line in _to_path(path_from).read_text().splitlines()
        if (stripped := line.strip()) != ""
    ]
    joined = "\n".join(keys)
    _ = _to_path("~/.ssh/authorized_keys").write_text(joined)


def _setup_sshd() -> None:
    path = _to_path("/etc/ssh/sshd_config")
    for from_, to in [
        ("#PermitRootLogin prohibit-password", "PermitRootLogin no"),
        ("#PubkeyAuthentication yes", "PubkeyAuthentication yes"),
        ("#PasswordAuthentication yes", "PasswordAuthentication no"),
    ]:
        _replace_line(path, from_, to)


# utilities


def _apt_install(*packages: str) -> None:
    _LOGGER.info("Updating 'apt'...")
    _run_commands("sudo apt -y update")
    desc = ", ".join(map(repr, packages))
    _LOGGER.info("Installing %s...", desc)
    joined = " ".join(packages)
    _run_commands(f"sudo apt -y install {joined}")


def _copyfile(
    path_from: Path | str, path_to: Path | str, /, *, executable: bool = False
) -> None:
    path_from, path_to = map(_to_path, [path_from, path_to])
    _unlink(path_to)
    _LOGGER.info("Copying %r -> %r...", str(path_from), str(path_to))
    path_to.parent.mkdir(parents=True, exist_ok=True)
    _ = copyfile(path_from, path_to)
    if executable:
        _set_executable(path_to)


def _download(url: str, path: Path | str, /) -> None:
    with urlopen(url) as response, _to_path(path).open(mode="wb") as fh:
        _ = fh.write(response.read())


def _dpkg_install(path: Path | str, /) -> None:
    _run_commands(f"sudo dpkg -i {path}")


def _get_latest_tag(owner: str, repo: str, /) -> str:
    _install_curl()
    _install_jq()
    return check_output(
        f'curl -s https://api.github.com/repos/{owner}/{repo}/releases/latest | jq -r ".tag_name"',
        shell=True,
        text=True,
    ).strip("\n")


def _get_local_bin() -> Path:
    return _to_path("~/.local/bin")


def _get_script_dir() -> Path:
    return _to_path(__file__).parent


def _have_command(cmd: str, /) -> bool:
    return which(cmd) is not None


def _is_root() -> bool:
    return geteuid() == 0


def _luarocks_install(package: str, /) -> None:
    _run_commands(f"sudo luarocks install {package}")


def _replace_line(path: Path | str, from_: str, to: str, /) -> None:
    path = _to_path(path)
    lines = path.read_text().splitlines()
    if all(line != from_ for line in lines):
        _LOGGER.debug("%r not found in %r", from_, str(path))
        return
    _LOGGER.info("Replacing %r -> %r in %r", from_, to, str(path))
    _run_commands(f"sudo sed -i 's|{from_}|{to}|' {path}")


def _run_commands(*cmds: str) -> None:
    is_root = _is_root()
    for cmd in cmds:
        cmd_use = cmd.replace("sudo", "") if is_root else cmd
        _ = check_call(cmd_use, shell=True)


def _set_executable(path: Path | str, /) -> None:
    path = _to_path(path)
    mode = path.stat().st_mode
    if mode & S_IXUSR:
        _LOGGER.debug("%r is already executable", str(path))
        return
    _LOGGER.info("Making %r executable...", str(path))
    path.chmod(mode | S_IXUSR)


def _setup_symlink(path_from: Path | str, path_to: Path | str, /) -> None:
    path_from, path_to = map(_to_path, [path_from, path_to])
    if path_from.is_symlink() and (path_from.resolve() == path_to.resolve()):
        _LOGGER.debug("%r -> %r already symlinked", str(path_from), str(path_to))
        return
    path_from.parent.mkdir(parents=True, exist_ok=True)
    _unlink(path_from)
    _LOGGER.info("Symlinking %r -> %r", str(path_from), str(path_to))
    path_from.symlink_to(path_to)


def _to_path(*parts: Path | str) -> Path:
    return Path(*parts).expanduser()


def _unlink(path: Path | str, /) -> None:
    path = _to_path(path)
    if path.exists() or path.is_symlink():
        _LOGGER.info("Removing %r...", str(path))
        path.unlink(missing_ok=True)


def _update_submodules() -> None:
    _LOGGER.info("Updating submodules...")
    _run_commands("git submodule update")


def _uv_tool_install(tool: str, /) -> None:
    if _have_command(tool):
        _LOGGER.debug("%r is already installed", tool)
        return
    _install_uv()
    _LOGGER.info("Installing %r...", tool)
    _run_commands(f"uv tool install {tool}")


@contextmanager
def _yield_download(url: str, /) -> Iterator[Path]:
    filename = _to_path(urlparse(url).path).name
    with TemporaryDirectory() as temp_dir:
        temp_file = _to_path(temp_dir, filename)
        _download(url, temp_file)
        yield temp_file


@contextmanager
def _yield_github_latest_download(
    owner: str, repo: str, filename_template: str, /
) -> Iterator[Path]:
    tag = _get_latest_tag(owner, repo)
    filename = Template(filename_template).substitute(tag=tag)
    url = f"https://github.com/{owner}/{repo}/releases/download/{tag}/{filename}"
    with _yield_download(url) as temp_file:
        yield temp_file


# main


def main(settings: _Settings, /) -> None:
    basicConfig(
        format="{asctime} | {levelname:8} | {message}",
        datefmt="%Y-%m-%d %H:%M:%S",
        style="{",
        level="DEBUG" if settings.verbose else "INFO",
    )
    _install_curl()
    _install_fish()
    _install_git(config=True)
    _install_neovim(path_config=f"{_get_script_dir()}/nvim")
    _install_npm()
    _install_python3_13_venv()
    _install_starship(config=True)
    _setup_bash()
    _setup_pdb()
    _setup_psql()
    _setup_sshd()
    _setup_zsh()
    if settings.age:
        _install_age()
    if settings.bat:
        _install_bat()
    if settings.bottom:
        _install_bottom(config=True)
    if settings.build_essential:
        _install_build_essential()
    if settings.caffeine:
        _install_caffeine()
    if settings.delta:
        _install_delta()
    if settings.direnv:
        _install_direnv(config=True)
    if settings.dust:
        _install_dust()
    if settings.eza:
        _install_eza()
    if settings.fd_find:
        _install_fd_find(config=True)
    if settings.fzf:
        _install_fzf(fzf_fish=True)
    if settings.gh:
        _install_gh()
    if settings.glab:
        _install_glab()
    if settings.just:
        _install_just()
    if settings.jq:
        _install_jq()
    if settings.luarocks:
        _install_luarocks()
    if settings.macchanger:
        _install_macchanger()
    if settings.ripgrep:
        _install_ripgrep(config=True)
    if settings.rsync:
        _install_rsync()
    if settings.shellcheck:
        _install_shellcheck()
    if settings.shfmt:
        _install_shfmt()
    if settings.sops:
        _install_sops(path_age="~/secrets/age/age-secret-key.txt")
    if settings.ssh_keys is not None:
        _setup_ssh_keys(settings.ssh_keys)
    if settings.stylua:
        _install_stylua()
    if settings.syncthing:
        _install_syncthing()
    if settings.tmux:
        _install_tmux()
    if settings.yq:
        _install_yq()
    if settings.zoom:
        _install_zoom()
    if settings.zoxide:
        _install_zoxide()

    _install_uv()  # after curl
    if settings.docker:
        _install_docker()  # after curl
    if settings.spotify:
        _install_spotify()  # after curl
    if settings.tailscale:
        _install_tailscale()  # after curl
    if settings.wezterm:
        _install_wezterm()  # after curl

    if settings.luacheck:
        _install_luacheck()  # after luarocks

    if settings.bump_my_version:
        _install_bump_my_version()  # after uv
    if settings.pre_commit:
        _install_pre_commit()  # after uv
    if settings.pyright:
        _install_pyright()  # after uv
    if settings.ruff:
        _install_ruff()  # after uv


main(_Settings.parse())

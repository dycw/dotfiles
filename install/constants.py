from pathlib import Path

ETC = Path("/etc")
SSHD_CONFIG = ETC / "ssh/sshd_config"


HOME = Path("~").expanduser()
XDG_CONFIG_HOME = HOME / "~/.config"
LOCAL_BIN = HOME / ".local/bin"
SSH = HOME / ".ssh"
AUTHORIZED_KEYS = SSH / "authorized_keys"
KNOWN_HOSTS = SSH / "known_hosts"


INSTALL = Path(__file__).parent
REPO_ROOT = INSTALL.parent
BOTTOM_TOML = REPO_ROOT / "bottom/bottom.toml"
FD_IGNORE = REPO_ROOT / "fd/ignore"
FISH = REPO_ROOT / "fish"
FISH_CONFIG = FISH / "config.fish"
FISH_ENV = FISH / "env.fish"
FISH_GIT = FISH / "git.fish"
FISH_WORK = FISH / "work.fish"
FZF_FISH = REPO_ROOT / "fzf/fzf.fish"
GIT = REPO_ROOT / "git"
GIT_CONFIG = GIT / "config"
GIT_IGNORE = GIT / "ignore"
NVIM = REPO_ROOT / "nvim"
PDBRC = REPO_ROOT / "pdb/pdbrc"
PSQLRC = REPO_ROOT / "psql/psqlrc"
RIPGREPRC = REPO_ROOT / "ripgrep/ripgreprc"
STARSHIP_TOML = REPO_ROOT / "starship/starship.toml"


__all__ = [
    "AUTHORIZED_KEYS",
    "BOTTOM_TOML",
    "ETC",
    "FD_IGNORE",
    "FISH",
    "FISH_CONFIG",
    "FISH_ENV",
    "FISH_GIT",
    "FISH_WORK",
    "FZF_FISH",
    "GIT",
    "GIT_CONFIG",
    "GIT_IGNORE",
    "HOME",
    "INSTALL",
    "KNOWN_HOSTS",
    "LOCAL_BIN",
    "NVIM",
    "PDBRC",
    "PSQLRC",
    "REPO_ROOT",
    "RIPGREPRC",
    "SSH",
    "SSHD_CONFIG",
    "STARSHIP_TOML",
    "XDG_CONFIG_HOME",
]

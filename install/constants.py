from pathlib import Path

HOME = Path("~").expanduser()

SSH = HOME / ".ssh"
LOCAL_BIN = HOME / ".local/bin"
XDG_CONFIG_HOME = HOME / "~/.config"

AUTHORIZED_KEYS = SSH / "authorized_keys"
KNOWN_HOSTS = SSH / "known_hosts"


INSTALL = Path(__file__).parent
REPO_ROOT = INSTALL.parent
BOTTOM = REPO_ROOT / "bottom"
BOTTOM_TOML = BOTTOM / "bottom.toml"
FD = REPO_ROOT / "fd"
FD_IGNORE = FD / "ignore"
FISH = REPO_ROOT / "fish"
FISH_CONFIG = FISH / "config.fish"
FISH_ENV = FISH / "env.fish"
FISH_GIT = FISH / "git.fish"
FISH_WORK = FISH / "work.fish"
FZF = REPO_ROOT / "fzf"
FZF_FISH = FZF / "fzf.fish"
GIT = REPO_ROOT / "git"
GIT_CONFIG = GIT / "config"
GIT_IGNORE = GIT / "ignore"
NVIM = REPO_ROOT / "nvim"
PDB = REPO_ROOT / "pdb"
PDBRC = PDB / "pdbrc"
PSQL = REPO_ROOT / "psql"
PSQLRC = PSQL / "psqlrc"
RIPGREP = REPO_ROOT / "ripgrep"
RIPGREPRC = RIPGREP / "ripgreprc"
STARSHIP = REPO_ROOT / "starship"
STARSHIP_TOML = STARSHIP / "starship.toml"


__all__ = [
    "AUTHORIZED_KEYS",
    "BOTTOM",
    "BOTTOM_TOML",
    "FD",
    "FD_IGNORE",
    "FISH",
    "FISH_CONFIG",
    "FISH_ENV",
    "FISH_GIT",
    "FISH_WORK",
    "FZF",
    "FZF_FISH",
    "GIT",
    "GIT_CONFIG",
    "GIT_IGNORE",
    "HOME",
    "INSTALL",
    "KNOWN_HOSTS",
    "LOCAL_BIN",
    "NVIM",
    "PDB",
    "PDBRC",
    "PSQL",
    "PSQLRC",
    "REPO_ROOT",
    "RIPGREP",
    "RIPGREPRC",
    "SSH",
    "STARSHIP",
    "STARSHIP_TOML",
    "XDG_CONFIG_HOME",
]

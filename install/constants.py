from pathlib import Path

HOME = Path("~").expanduser()
KNOWN_HOSTS = HOME / ".ssh/known_hosts"
LOCAL_BIN = HOME / ".local/bin"
XDG_CONFIG_HOME = HOME / "~/.config"


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
PDB = REPO_ROOT / "pdb"
PDBRC = PDB / "pdbrc"
PSQL = REPO_ROOT / "psql"
PSQLRC = PSQL / "psqlrc"


__all__ = [
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
    "PDB",
    "PDBRC",
    "PSQL",
    "PSQLRC",
    "REPO_ROOT",
    "XDG_CONFIG_HOME",
]

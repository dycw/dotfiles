from __future__ import annotations

from pathlib import Path

ETC = Path("/etc")
HOME = Path("~").expanduser()


ETC_SSH = ETC / "ssh"
LOGROTATE_D = ETC / "logrotate.d"
RESOLV_CONF = ETC / "resolv.conf"
BASHRC = HOME / ".bashrc"
LOCAL_BIN = HOME / ".local/bin"
PDBRC = HOME / ".pdbrc"
PSQLRC = HOME / ".psqlrc"
SSH = HOME / ".ssh"
XDG_CONFIG_HOME = HOME / ".config"


SSHD_CONFIG = ETC_SSH / "sshd_config"
AUTHORIZED_KEYS = SSH / "authorized_keys"
SSH_CONFIG = SSH / "config"
SSH_CONFIG_D = SSH / "config.d"
KNOWN_HOSTS = SSH / "known_hosts"
CONFIG_BOTTOM_TOML = XDG_CONFIG_HOME / "bottom/bottom.toml"
CONFIG_DIRENV = XDG_CONFIG_HOME / "direnv"
CONFIG_FISH = XDG_CONFIG_HOME / "fish"
CONFIG_FISH_CONF_D = CONFIG_FISH / "conf.d"
CONFIG_FISH_FUNCTIONS = CONFIG_FISH / "functions"
CONFIG_GIT = XDG_CONFIG_HOME / "git"
CONFIG_GLAB_CONFIG_YML = XDG_CONFIG_HOME / "glab-cli/config.yml"
CONFIG_NVIM = XDG_CONFIG_HOME / "nvim"
CONFIG_SOPS_AGE = XDG_CONFIG_HOME / "sops/age/keys.txt"
CONFIG_STARSHIP_TOML = XDG_CONFIG_HOME / "starship.toml"
CONFIG_TMUX = XDG_CONFIG_HOME / "tmux"
CONFIG_TMUX_CONF_OH_MY_TMUX = CONFIG_TMUX / "tmux.conf"
CONFIG_TMUX_CONF_LOCAL = CONFIG_TMUX / "tmux.conf.local"
CONFIG_WEZTERM_LUA = XDG_CONFIG_HOME / "wezterm/wezterm.lua"


PATH_INSTALL = Path(__file__).parent
REPO_ROOT = PATH_INSTALL.parent


PATH_CONFIGS = PATH_INSTALL / "configs"
CONFIGS_LINUX = PATH_CONFIGS / "linux"
LINUX_RESOLV_CONF = CONFIGS_LINUX / "resolv.conf"


REPO_BOTTOM_TOML = REPO_ROOT / "bottom/bottom.toml"
REPO_DIRENV = REPO_ROOT / "direnv"
REPO_FD_IGNORE = REPO_ROOT / "fd/ignore"
REPO_FZF_FISH = REPO_ROOT / "fzf/fzf.fish"
REPO_GIT = REPO_ROOT / "git"
REPO_GIT_CONFIG = REPO_GIT / "config"
REPO_GIT_IGNORE = REPO_GIT / "ignore"
REPO_NVIM = REPO_ROOT / "nvim"
REPO_PDBRC = REPO_ROOT / "pdb/pdbrc"
REPO_PSQLRC = REPO_ROOT / "psql/psqlrc"
REPO_RIPGREPRC = REPO_ROOT / "ripgrep/ripgreprc"
REPO_SSH = REPO_ROOT / "ssh"
REPO_SSH_DEFAULT = REPO_SSH / "default"
REPO_SSH_GITLAB = REPO_SSH / "gitlab"
REPO_STARSHIP_TOML = REPO_ROOT / "starship/starship.toml"
REPO_TMUX = REPO_ROOT / "tmux"
REPO_TMUX_CONF_OH_MY_TMUX = REPO_TMUX / ".tmux/.tmux.conf"
REPO_TMUX_CONF_LOCAL = REPO_TMUX / "tmux.conf.local"
REPO_WEZTERM_LUA = REPO_ROOT / "wezterm/wezterm.lua"


__all__ = [
    "AUTHORIZED_KEYS",
    "BASHRC",
    "CONFIGS_LINUX",
    "CONFIG_BOTTOM_TOML",
    "CONFIG_DIRENV",
    "CONFIG_FISH",
    "CONFIG_FISH_CONF_D",
    "CONFIG_FISH_FUNCTIONS",
    "CONFIG_GIT",
    "CONFIG_GLAB_CONFIG_YML",
    "CONFIG_NVIM",
    "CONFIG_SOPS_AGE",
    "CONFIG_STARSHIP_TOML",
    "CONFIG_TMUX",
    "CONFIG_TMUX_CONF_LOCAL",
    "CONFIG_TMUX_CONF_OH_MY_TMUX",
    "CONFIG_WEZTERM_LUA",
    "ETC",
    "ETC_SSH",
    "HOME",
    "KNOWN_HOSTS",
    "LINUX_RESOLV_CONF",
    "LOCAL_BIN",
    "LOGROTATE_D",
    "PATH_CONFIGS",
    "PATH_INSTALL",
    "PDBRC",
    "PSQLRC",
    "REPO_BOTTOM_TOML",
    "REPO_DIRENV",
    "REPO_FD_IGNORE",
    "REPO_FISH",
    "REPO_FISH_CONFIG",
    "REPO_FISH_ENV",
    "REPO_FISH_GIT",
    "REPO_FISH_WORK",
    "REPO_FZF_FISH",
    "REPO_GIT",
    "REPO_GIT_CONFIG",
    "REPO_GIT_IGNORE",
    "REPO_NVIM",
    "REPO_PDBRC",
    "REPO_PSQLRC",
    "REPO_RIPGREPRC",
    "REPO_ROOT",
    "REPO_SSH",
    "REPO_SSH_DEFAULT",
    "REPO_SSH_GITLAB",
    "REPO_STARSHIP_TOML",
    "REPO_TMUX",
    "REPO_TMUX_CONF_LOCAL",
    "REPO_TMUX_CONF_OH_MY_TMUX",
    "REPO_WEZTERM_LUA",
    "RESOLV_CONF",
    "SSH",
    "SSHD_CONFIG",
    "SSH_CONFIG",
    "SSH_CONFIG_D",
    "XDG_CONFIG_HOME",
]

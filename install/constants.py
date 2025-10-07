from pathlib import Path

KNOWN_HOSTS = Path("~/.ssh/known_hosts").expanduser()
LOCAL_BIN = Path("~/.local/bin").expanduser()


__all__ = ["KNOWN_HOSTS", "LOCAL_BIN"]

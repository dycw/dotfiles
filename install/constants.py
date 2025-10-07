from pathlib import Path

KNOWN_HOSTS = Path("~/.ssh/known_hosts").expanduser()


__all__ = ["KNOWN_HOSTS"]

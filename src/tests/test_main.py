from __future__ import annotations

from dotfiles import __version__


class TestVersion:
    def test_main(self) -> None:
        assert isinstance(__version__, str)

from typing import TypeVar


T = TypeVar("T")


try:
    from hypothesis.strategies import SearchStrategy
except ModuleNotFoundError:
    pass
else:

    def draw(strategy: SearchStrategy[T]) -> T:
        """Draw an example from a strategy."""

        return strategy.example()

    class data:  # noqa:N801
        """Mimics instances of data()."""

        @classmethod
        def draw(cls, strategy: SearchStrategy[T]) -> T:
            """Draw an example from a strategy."""

            return draw(strategy)

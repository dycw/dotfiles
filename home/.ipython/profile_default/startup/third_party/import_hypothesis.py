from contextlib import suppress
from typing import TypeVar

from hypothesis import assume  # noqa: F401
from hypothesis import given  # noqa: F401
from hypothesis import HealthCheck  # noqa: F401
from hypothesis import infer  # noqa: F401
from hypothesis import reproduce_failure  # noqa: F401
from hypothesis import settings  # noqa: F401
from hypothesis.strategies import booleans  # noqa: F401
from hypothesis.strategies import complex_numbers  # noqa: F401
from hypothesis.strategies import DataObject  # noqa: F401
from hypothesis.strategies import dictionaries  # noqa: F401
from hypothesis.strategies import fixed_dictionaries  # noqa: F401
from hypothesis.strategies import floats  # noqa: F401
from hypothesis.strategies import from_type  # noqa: F401
from hypothesis.strategies import integers  # noqa: F401
from hypothesis.strategies import just  # noqa: F401
from hypothesis.strategies import lists  # noqa: F401
from hypothesis.strategies import none  # noqa: F401
from hypothesis.strategies import sampled_from  # noqa: F401
from hypothesis.strategies import SearchStrategy
from hypothesis.strategies import sets  # noqa: F401
from hypothesis.strategies import shared  # noqa: F401
from hypothesis.strategies import text  # noqa: F401
from hypothesis.strategies import tuples  # noqa: F401


with suppress(ModuleNotFoundError):
    from hypothesis.extra.numpy import array_dtypes  # noqa: F401
    from hypothesis.extra.numpy import array_shapes  # noqa: F401

T = TypeVar("T")


def draw(strategy: SearchStrategy[T]) -> T:
    """Draw an example from a strategy."""

    return strategy.example()


class data:  # noqa:N801
    """Mimics instances of data()."""

    @classmethod
    def draw(cls, strategy: SearchStrategy[T]) -> T:
        """Draw an example from a strategy."""

        return draw(strategy)

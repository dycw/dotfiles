from typing import Tuple
from typing import TypeVar


try:
    from numpy import ndarray
    from pandas import DataFrame
    from pandas import Series
    from sklearn.base import TransformerMixin
except ModuleNotFoundError:
    pass
else:
    ArrayLike = TypeVar("ArrayLike", ndarray, Series, DataFrame)

    def apply_transform(scaler: TransformerMixin, x: ArrayLike) -> ArrayLike:
        if isinstance(x, ndarray):
            return scaler.transform(x)
        elif isinstance(x, Series):
            return Series(apply_transform(scaler, x.to_numpy()), x.index, name=x.name)
        elif isinstance(x, DataFrame):
            return DataFrame(apply_transform(scaler, x.to_numpy()), x.index, x.columns)
        else:
            raise TypeError(f"Invalid type: {type(x).__name__}")

    def apply_inverse_transform(scaler: TransformerMixin, x: ArrayLike) -> ArrayLike:
        if isinstance(x, ndarray):
            return scaler.inverse_transform(x)
        elif isinstance(x, Series):
            return Series(
                apply_inverse_transform(scaler, x.to_numpy()),
                x.index,
                name=x.name,
            )
        elif isinstance(x, DataFrame):
            return DataFrame(
                apply_inverse_transform(scaler, x.to_numpy()),
                x.index,
                x.columns,
            )
        else:
            raise TypeError(f"Invalid type: {type(x).__name__}")

    def fit_transform_scaler(
        scaler: TransformerMixin,
        x: ArrayLike,
    ) -> Tuple[TransformerMixin, ArrayLike]:
        fitted = scaler.fit(x)
        return fitted, apply_transform(fitted, x)

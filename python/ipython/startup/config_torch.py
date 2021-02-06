from itertools import repeat
from typing import List
from typing import Optional
from typing import Sequence
from typing import Union


try:
    from holoviews import Curve
    from holoviews import Dimension
    from holoviews import Layout
    from holoviews import NdOverlay
    from more_itertools import one
    from numpy import concatenate
    from numpy import ndarray
    from numpy.random import choice
    from numpy.random import randint
    from pandas import DataFrame
    from pandas import DatetimeIndex
    from pandas import RangeIndex
    from pandas import Timestamp
    from pandas.tseries.offsets import DateOffset
    from skorch import NeuralNet
    from skorch.callbacks import Checkpoint
    from torch.nn import Module
except ModuleNotFoundError:
    pass
else:

    def view_predictions(
        net: Module,
        *X_y: ndarray,
        indices: Optional[List[DatetimeIndex]] = None,
        labels: Optional[List[str]] = None,
        length: Optional[Union[int, float, DateOffset]] = None,
    ) -> Layout:
        if not X_y:
            raise ValueError("Expected at least 2 arrays to be passed in")
        n_args = len(X_y)
        n_pairs, r = divmod(n_args, 2)
        if r != 0:
            raise ValueError(f"Expected an even number of arrays; got {n_args}")
        if indices is None:
            indices_use: Sequence[Optional[DatetimeIndex]] = list(
                repeat(None, n_pairs),
            )
        else:
            if (n_indices := len(indices)) != n_pairs:
                raise ValueError(f"Expected {n_pairs} index/indices; got {n_indices}")
            indices_use = indices
        if labels is None:
            labels_use: Sequence[Optional[str]] = list(repeat(None, n_pairs))
        else:
            if (n_labels := len(labels)) != n_pairs:
                raise ValueError(f"Expected {n_pairs} label(s); got {n_labels}")
            labels_use = labels

        plots: List[NdOverlay] = []
        for i, (X, y, index, label) in enumerate(
            zip(X_y[::2], X_y[1::2], indices_use, labels_use),
        ):
            y_pred = net.predict(X)
            n = len(X)
            paired = DataFrame(
                concatenate([y, y_pred], axis=1),
                RangeIndex(n, name="index")
                if index is None
                else index.rename("datetime"),
                ["actual", "pred"],
            )
            if length is None:
                view = paired
            elif isinstance(length, int):
                start = randint(n - length)
                end = start + length
                view = paired.iloc[start:end]
            elif isinstance(length, float):
                start = randint(n * (1.0 - length))
                end = start + int(round(n * length))
                view = paired.iloc[start:end]
            elif isinstance(length, DateOffset):
                if index is None:
                    raise ValueError("Expected indices if the length is a DateOffset")
                while True:
                    start = Timestamp(choice(index))
                    end = start + length
                    if end <= index[-1]:
                        view = paired.loc[start:end]
                        break
            else:
                raise TypeError(f"Invalid type: {type(length).__name__}")
            curves = {
                key: Curve(
                    (view.index, col),
                    kdims=[Dimension(f"x_{i}", label=view.index.name)],
                    vdims=[Dimension(f"y_{i}", label="y")],
                    **({} if label is None else {"label": label}),
                )
                for key, col in view.items()
            }
            plot = NdOverlay(curves).opts(show_grid=True)
            plots.append(plot)
        if isinstance(net, NeuralNet):
            epoch = net.history[-1]["epoch"]
            try:
                dirname = one(
                    x for x in net.callbacks if isinstance(x, Checkpoint)
                ).dirname
            except ValueError:
                label = f"Epoch {epoch}"
            else:
                label = f"Epoch {epoch} ({dirname})"
            label_kwargs = {"label": label}
        else:
            label_kwargs = {}
        return Layout(plots, **label_kwargs)

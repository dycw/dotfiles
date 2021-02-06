from functools import reduce
from itertools import chain
from operator import add
from typing import Any
from typing import List
from typing import Optional
from typing import Tuple
from typing import Type
from typing import Union


try:
    from holoviews import Dimension, HeatMap
    from holoviews import DynamicMap
    from holoviews import renderer
    from holoviews import Scatter
    from pandas import DataFrame
    from pandas import MultiIndex
    from pandas import Series
    from panel import panel
    from panel import Row
    from param import depends
    from param import ObjectSelector
    from param import Parameterized
except ModuleNotFoundError:
    pass
else:
    BOKEH_RENDERER = renderer("bokeh")

    class DataFrameExplorer:
        def __init__(self, data: Union[Series, DataFrame]) -> None:
            self.data = data
            if isinstance(self.data, Series):
                if not isinstance(name := self.data.name, str):
                    raise TypeError(
                        "Expected the series name to be a string; "
                        f"got {type(name).__name__}",
                    )
            elif isinstance(self.data, DataFrame):
                for column in self.data.columns:
                    if not isinstance(column, str):
                        raise TypeError(
                            "Expected the column names to be strings; "
                            f"got {type(column).__name__}",
                        )
            else:
                raise TypeError(f"Invalid type: {type(self.data).__name__}")
            self._index = self.data.index
            if not isinstance(index := self._index, MultiIndex):
                raise TypeError(
                    "Expected the index to be a MultiIndex; "
                    f"got {type(index).__name__}",
                )
            self.kdims = self._index.names
            for kdim in self.kdims:
                if not isinstance(kdim, str):
                    raise TypeError(
                        "Expected the index names to be strings; "
                        f"got {type(kdim).__name__}",
                    )
            self._kdim_str_plus_kdims = list(chain(["kdim"], self.kdims))

            class _Explorer(Parameterized):
                def _plot_series(self, series: Series) -> Any:
                    raise NotImplementedError("Please implement this method")

                def _plot_series_opts(self, series: Series) -> Any:
                    return self._plot_series(series).opts(
                        framewise=True,
                        tools=["hover"],
                    )

                def _query_except(
                    self,
                    dfe: DataFrameExplorer,
                    kdims: List[str],
                    series: Series,
                ) -> Tuple[Series, str]:
                    parts: List[str] = []
                    for kdim in dfe.kdims:
                        if kdim not in kdims:
                            value = getattr(self, kdim)
                            series = series.loc[
                                series.index.get_level_values(kdim) == value
                            ]
                            parts.append(f"{kdim}={value}")
                    return series, ", ".join(parts)

            self._Explorer = _Explorer

        def heatmap(self) -> Row:
            self._check_nlevels(3)
            dfe = self

            class Explorer(self._Explorer):  # type: ignore
                kdim1 = ObjectSelector(default=self.kdims[0], objects=self.kdims)
                kdim2 = ObjectSelector(default=self.kdims[1], objects=self.kdims)

                def _plot_series(self, series: Series) -> HeatMap:
                    data, label = self._query_except(
                        dfe,
                        [self.kdim1, self.kdim2],
                        series,
                    )
                    vdim = series.name
                    label = f"{vdim} = f({self.kdim1}, {self.kdim2} | {label})"
                    return HeatMap(
                        data,
                        kdims=[self.kdim1, self.kdim2],
                        vdims=vdim,
                        label=label,
                    ).opts(colorbar=True)

            return self._make_plot(Explorer, ["kdim1", "kdim2"])

        def scatter(self, *, size: Optional[int] = None, fixed: bool = False) -> Row:
            self._check_nlevels(2)
            dfe = self

            class Explorer(self._Explorer):  # type: ignore
                kdim = ObjectSelector(default=self.kdims[0], objects=self.kdims)

                def _plot_series(self, series: Series) -> Scatter:
                    data, label = self._query_except(dfe, [self.kdim], series)
                    vdim = series.name
                    label = f"{vdim} = f({self.kdim} | {label})"
                    scatter = Scatter(
                        data,
                        kdims=self.kdim,
                        vdims=vdim,
                        label=label,
                    ).opts(show_grid=True, **({} if size is None else {"size": size}))
                    if fixed:
                        new_vdim = Dimension(
                            vdim,
                            soft_range=(series.min(), series.max()),
                        )
                        return scatter.redim(**{vdim: new_vdim})
                    else:
                        return scatter

            return self._make_plot(Explorer, ["kdim"])

        def _check_nlevels(self, n: int) -> None:
            if (nlevels := self._index.nlevels) < n:
                raise ValueError(
                    f"Expected the index to have at least {n} levels; "
                    f"got {nlevels}",
                )

        def _make_plot(self, explorer: Type[Parameterized], kdims: List[str]) -> Row:
            unique_values = {
                kdim: self._index.get_level_values(kdim).drop_duplicates().sort_values()
                for kdim in self.kdims
            }
            selectors = {
                k: ObjectSelector(default=v[0], objects=v)
                for k, v in unique_values.items()
            }

            kdims_strs_plus_kdims = list(chain(kdims, self.kdims))
            data = self.data

            class Extended(
                type("Explorer", (explorer,), selectors),  # type: ignore
            ):
                @depends(*kdims_strs_plus_kdims)  # type: ignore
                def load_data(self) -> Any:
                    if isinstance(data, Series):
                        return self._plot_series_opts(data)
                    elif isinstance(data, DataFrame):
                        parts = [self._plot_series_opts(sr) for _, sr in data.items()]
                        return reduce(add, parts).cols(1)
                    else:
                        raise TypeError(f"Invalid type: {type(data).__name__}")

            extended = Extended()
            dmap = DynamicMap(extended.load_data)
            return Row(panel(extended.param, parameters=kdims_strs_plus_kdims), dmap)

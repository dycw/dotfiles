import cvxpy as cp
import dtale
import ib_insync
import joblib
import matplotlib.pyplot as plt
import pytest
import seaborn as sns
import skorch
import sktime
import statsmodels.api as sm
from arch.bootstrap import IIDBootstrap
from arch.bootstrap import optimal_block_length
from arch.bootstrap import StationaryBootstrap
from atomic_write_path import atomic_write_path
from box import Box
from contexttimer import Timer
from ib_insync.util import dataclassAsDict
from ib_insync.util import dataclassAsTuple
from ib_insync.util import startLoop
from joblib import delayed
from joblib import Memory
from joblib import Parallel
from loguru import logger
from pyinstrument_decorator import profile
from pytest import fixture
from pytest import mark
from pytest import param
from pytest import raises
from pytest import warns
from pytorch_lightning import Trainer
from pytorch_lightning.callbacks import ModelCheckpoint
from pytorch_lightning.loggers import TensorBoardLogger
from pytz import UTC
from ray import get
from ray import init
from ray import put
from ray import remote
from ray import shutdown
from ray import wait
from ray.remote_function import RemoteFunction
from seaborn import catplot
from seaborn import distplot
from seaborn import heatmap
from seaborn import jointplot
from seaborn import kdeplot
from seaborn import pairplot
from seaborn import violinplot
from skits.pipeline import ForecasterPipeline
from skits.preprocessing import DifferenceTransformer
from skits.preprocessing import ReversibleImputer
from sklearn_pandas import DataFrameMapper
from skorch import NeuralNet
from skorch import NeuralNetClassifier
from skorch import NeuralNetRegressor
from skorch.callbacks import Checkpoint
from skorch.callbacks import EarlyStopping
from skorch.callbacks import LoadInitState
from skorch.callbacks import ProgressBar
from skorch.callbacks import TrainEndCheckpoint
from skorch.exceptions import NotInitializedError
from skorch.helper import predefined_split
from sktime.classification.compose import TimeSeriesForestClassifier
from sktime.classification.distance_based import KNeighborsTimeSeriesClassifier
from sktime.forecasting.compose import RecursiveRegressionForecaster
from sktime.forecasting.compose import ReducedRegressionForecaster
from sktime.forecasting.exp_smoothing import ExponentialSmoothing
from sktime.forecasting.model_selection import CutoffSplitter
from sktime.forecasting.model_selection import ForecastingGridSearchCV
from sktime.forecasting.model_selection import SingleWindowSplitter
from sktime.forecasting.model_selection import SlidingWindowSplitter
from sktime.forecasting.model_selection import temporal_train_test_split
from sktime.forecasting.naive import NaiveForecaster
from sktime.performance_metrics.forecasting import sMAPE
from sktime.performance_metrics.forecasting import smape_loss
from sktime.transformers.series_as_features.compose import RowTransformer
from sktime.transformers.series_as_features.reduce import Tabularizer
from sktime.transformers.series_as_features.segment import RandomIntervalSegmenter
from sktime.transformers.single_series.detrend import Detrender
from sktime.utils.plotting.forecasting import plot_ys
from sktime.utils.time_series import time_series_slope
from statsmodels.regression.linear_model import OLS
from statsmodels.stats.outliers_influence import variance_inflation_factor
from statsmodels.tsa.ar_model import AutoReg
from statsmodels.tsa.stattools import acf
from tqdm import tqdm
from tqdm import trange
from tsfresh import extract_features
from tsfresh import select_features
from tsfresh.feature_extraction.settings import ComprehensiveFCParameters
from tsfresh.feature_extraction.settings import EfficientFCParameters
from tsfresh.feature_extraction.settings import MinimalFCParameters
from tsfresh.utilities.dataframe_functions import roll_time_series
from typeguard import typechecked
from wrapt import decorator

__all__ = [
    ############################################################################
    # third party #
    ############################################################################
    "cp",
    "dtale",
    "ib_insync",
    "joblib",
    "plt",
    "pytest",
    "sns",
    "skorch",
    "sktime",
    "sm",
    # arch .....................................................................
    "IIDBootstrap",
    "optimal_block_length",
    "StationaryBootstrap",
    # atomic_write_path ........................................................
    "atomic_write_path",
    # box ......................................................................
    "Box",
    # contexttimer .............................................................
    "Timer",
    # ib-insync ................................................................
    "startLoop",
    "dataclassAsDict",
    "dataclassAsTuple",
    # joblib ...................................................................
    "delayed",
    "Memory",
    "Parallel",
    # loguru ...................................................................
    "logger",
    # pyinstrument-decorator ...................................................
    "profile",
    # pytest ...................................................................
    "fixture",
    "mark",
    "param",
    "raises",
    "warns",
    # pytorch_lightning ........................................................
    "Trainer",
    "ModelCheckpoint",
    "TensorBoardLogger",
    # pytz .....................................................................
    "UTC",
    # ray ......................................................................
    "get",
    "init",
    "put",
    "remote",
    "shutdown",
    "wait",
    "RemoteFunction",
    # seaborn ..................................................................
    "catplot",
    "distplot",
    "heatmap",
    "jointplot",
    "kdeplot",
    "pairplot",
    "violinplot",
    # skits ....................................................................
    "ForecasterPipeline",
    "DifferenceTransformer",
    "ReversibleImputer",
    # sklearn_pandas ...........................................................
    "DataFrameMapper",
    # skorch ...................................................................
    "NeuralNet",
    "NeuralNetClassifier",
    "NeuralNetRegressor",
    "Checkpoint",
    "EarlyStopping",
    "LoadInitState",
    "ProgressBar",
    "TrainEndCheckpoint",
    "NotInitializedError",
    "predefined_split",
    # sktime ...................................................................
    "TimeSeriesForestClassifier",
    "KNeighborsTimeSeriesClassifier",
    "RecursiveRegressionForecaster",
    "ReducedRegressionForecaster",
    "ExponentialSmoothing",
    "CutoffSplitter",
    "ForecastingGridSearchCV",
    "SingleWindowSplitter",
    "SlidingWindowSplitter",
    "temporal_train_test_split",
    "NaiveForecaster",
    "sMAPE",
    "smape_loss",
    "RowTransformer",
    "Tabularizer",
    "RandomIntervalSegmenter",
    "Detrender",
    "plot_ys",
    "time_series_slope",
    # statsmodels ..............................................................
    "OLS",
    "variance_inflation_factor",
    "AutoReg",
    "acf",
    # tqdm .....................................................................
    "tqdm",
    "trange",
    # tsfresh ..................................................................
    "extract_features",
    "select_features",
    "ComprehensiveFCParameters",
    "EfficientFCParameters",
    "MinimalFCParameters",
    "roll_time_series",
    # typeguard ................................................................
    "typechecked",
    # wrapt ....................................................................
    "decorator",
]

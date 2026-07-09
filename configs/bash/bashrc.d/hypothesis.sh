# shellcheck shell=sh
hypothesis_ci() { export HYPOTHESIS_PROFILE=ci; }
hypothesis_default() { export HYPOTHESIS_PROFILE=default; }
hypothesis_dev() { export HYPOTHESIS_PROFILE=dev; }

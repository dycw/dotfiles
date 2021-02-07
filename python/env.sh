#!/usr/bin/env bash

if command -v python >/dev/null 2>&1; then
	export MKL_NUM_THREADS=1
fi

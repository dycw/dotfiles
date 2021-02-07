#!/usr/bin/env bash

if command -v jupyter >/dev/null 2>&1; then
	alias juplab='jupyter lab'
	alias jupnb='jupyter notebook'
fi

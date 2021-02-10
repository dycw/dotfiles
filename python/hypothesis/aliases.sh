#!/usr/bin/env bash

if command -v python >/dev/null 2>&1; then
	alias hypothesis-ci="export HYPOTHESIS_PROFILE=ci"
	alias hypothesis-debug="export HYPOTHESIS_PROFILE=debug"
	alias hypothesis-default="export HYPOTHESIS_PROFILE=default"
	alias hypothesis-dev="export HYPOTHESIS_PROFILE=dev"
fi

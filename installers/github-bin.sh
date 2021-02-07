#!/usr/bin/env bash

tmp_dir="$1"
url="$2"
cd "$tmp_dir" || exit
name=binary
wget --output-document="$name" "$url"

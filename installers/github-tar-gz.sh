#!/usr/bin/env bash

tmp_dir="$1"
url="$2"
cd "$tmp_dir" || exit
name=archive.tar.gz
wget --output-document="$name" "$url"
tar -zxvf "$name"
rm "$name"

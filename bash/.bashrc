#!/usr/bin/env bash

if [ -d /opt/homebrew/bin ]; then
	PATH=/opt/homebrew/bin${PATH:+:${PATH}}
fi

#!/usr/bin/env sh
if (command -v gh >/dev/null 2>&1) && (git remote get-url origin 2>/dev/null | grep -q github); then
	printf "\n==== github ==================================================================="
	gh pr status
fi

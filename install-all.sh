#!/usr/bin/env sh
model=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')
if [ "$model" = "Mac14,12" ]; then
	[ "$(scutil --get ComputerName)" = DW-Mac ] || sudo scutil --set ComputerName DW-Mac
fi

MACHINE_TYPE=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')
case "$MACHINE_TYPE" in
Mac14,12) echo "This is a Mac mini" ;;
MacBook*) echo "This is a MacBook" ;;
*) echo "Unknown model: $MACHINE_TYPE" ;;
esac

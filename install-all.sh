#!/usr/bin/env sh

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# machine-specific
MACHINE_TYPE=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')
case "$MACHINE_TYPE" in
Mac14,12)
	echo_date "Detected Mac-Mini..."

	if [ "$(scutil --get ComputerName)" = 'DW-Mac' ]; then
		echo_date 'Computer name is already set'
	else
		echo_date 'Setting computer name...'
		sudo scutil --set ComputerName DW-Mac
	fi

	if [ "$(scutil --get HostName)" = 'DW-Mac' ]; then
		echo_date 'Host name is already set'
	else
		echo_date 'Setting host name...'
		sudo scutil --set HostName DW-Mac
	fi
	;;
MacBook10,1) echo_date "Detected MacBook.." ;;
*) echo_date "Unknown \$MACHINE_TYPE: ${MACHINE_TYPE}" ;;
esac

#!/usr/bin/env sh

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# machine-specific
MACHINE_TYPE=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')
case "$MACHINE_TYPE" in
Mac14,12)
	echo_date "Detected Mac-Mini..."

	# computer name
	if [ "$(scutil --get ComputerName)" = 'DW-Mac' ]; then
		echo_date 'Computer name is already set'
	else
		echo_date 'Setting computer name...'
		sudo scutil --set ComputerName DW-Mac
	fi

	# host name
	if [ "$(scutil --get HostName)" = 'DW-Mac' ]; then
		echo_date 'Host name is already set'
	else
		echo_date 'Setting host name...'
		sudo scutil --set HostName DW-Mac
	fi

	# local host name
	if [ "$(scutil --get LocalHostName)" = 'DW-Mac' ]; then
		echo_date 'Local host name is already set'
	else
		echo_date 'Setting local host name...'
		sudo scutil --set LocalHostName DW-Mac
	fi

	# power management
	set_pm_value() {
		key=$1
		desired=$2
		current=$(pmset -g custom | awk "/[[:space:]]${key}[[:space:]]/ {print \$2}")
		if [ "$current" = "$desired" ]; then
			echo_date "'$key' is already set"
		else
			echo_date "Setting '$key'..."
			sudo pmset -a "$key" "$desired"
		fi
	}
	set_pm_value sleep 0
	set_pm_value disksleep 10
	set_pm_value displaysleep 10

	;;
MacBook10,1) echo_date "Detected MacBook.." ;;
*) echo_date "Unknown \$MACHINE_TYPE: ${MACHINE_TYPE}" ;;
esac

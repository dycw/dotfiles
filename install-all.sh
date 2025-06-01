#!/usr/bin/env sh

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# machine-specific
MACHINE_TYPE=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')
case "$MACHINE_TYPE" in
Mac14,12)
	echo_date "Detected Mac-Mini..."

	# power management
	set_pm_value() {
		key=$1
		value=$2
		current=$(pmset -g custom | awk "/[[:space:]]${key}[[:space:]]/ {print \$2}")
		if [ "${current}" = "${value}" ]; then
			echo_date "'${key}' is already set"
		else
			echo_date "Setting ${key}..."
			sudo pmset -a "${key}" "${value}"
		fi
	}
	set_pm_value sleep 0
	set_pm_value disksleep 10
	set_pm_value displaysleep 10

	# system configuration
	set_scutil_value() {
		key=$1
		expected=$2
		current=$(scutil --get "${key}" 2>/dev/null || echo "")
		if [ "${current}" = "${value}" ]; then
			echo_date "'${key}' is already set"
		else
			echo_date "Setting ${key}..."
			sudo scutil --set "${key}" "${expected}"
		fi
	}
	set_scutil_value ComputerName 'DW-Mac'
	set_scutil_value HostName 'DW-Mac'
	set_scutil_value LocalHostName 'DW-Mac'
	;;
MacBook10,1) echo_date "Detected MacBook.." ;;
*) echo_date "Unknown \$MACHINE_TYPE: ${MACHINE_TYPE}" ;;
esac

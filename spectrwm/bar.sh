#!/bin/bash

initialize() {
	DEFAULT_DELAY=15

	SEPARATOR="  .:.  "
	DELAY=$([ "$1" != "" ] && echo $1 || echo $DEFAULT_DELAY)
}

batteryOutput() {
	BATTERY_CAPACITY=`cat /sys/class/power_supply/BAT0/capacity`
	BATTERY_STATUS=`cat /sys/class/power_supply/BAT0/status`

	if [ "$BATTERY_STATUS" = "Charging" ]
	then
		BATTERY_OUTPUT="$BATTERY_CAPACITY%+"
	else
		BATTERY_OUTPUT="$BATTERY_CAPACITY%"
	fi
}

loadOutput() {
	LOAD_ONE=`cat /proc/loadavg | cut -d" " -f 1`
	LOAD_FIVE=`cat /proc/loadavg | cut -d" " -f 2`
	LOAD_FIFTEEN=`cat /proc/loadavg | cut -d" " -f 3`

	LOAD_OUTPUT="$LOAD_ONE / $LOAD_FIVE / $LOAD_FIFTEEN"
}

timeOutput() {
	TIME_OUTPUT=`date +"%-l:%M%P"`
}

dateOutput() {
	DATE_OUTPUT=`date +"%A, %B --"`
	DATE=`date +%-d`

	case $DATE in
		1|21|31) SUFFIX="st"; ;;
		2|22) SUFFIX="nd"; ;;
		3|23) SUFFIX="rd"; ;;
		*) SUFFIX="th"; ;;
	esac

	DATE_OUTPUT=`sed -e s/--/$DATE$SUFFIX/ <<< "$DATE_OUTPUT"`
}

while :; do
	initialize $@

	batteryOutput
	loadOutput
	dateOutput
	timeOutput

	echo -n $LOAD_OUTPUT
	echo -n "$SEPARATOR"
	echo -n $BATTERY_OUTPUT
	echo -n "$SEPARATOR"
	echo -n $DATE_OUTPUT
	echo -n "$SEPARATOR"
	echo -n $TIME_OUTPUT
	echo " "

	sleep $DELAY
done

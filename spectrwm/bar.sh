#!/bin/bash

initialize() {
	DEFAULT_DELAY=15

	SEPARATOR="  .:.  "
	DELAY=$([ "$1" != "" ] && echo $1 || echo $DEFAULT_DELAY)
}

batteryOutput() {
	if [ -f "/sys/class/power_supply/BAT0/status" ]
	then
		BATTERY_CAPACITY=`cat /sys/class/power_supply/BAT0/capacity`
		BATTERY_STATUS=`cat /sys/class/power_supply/BAT0/status`
		BATTERY_OUTPUT=""

		if [ "$BATTERY_STATUS" = "Charging" ]
		then
			BATTERY_OUTPUT="$BATTERY_CAPACITY%+"
		else
			BATTERY_OUTPUT="$BATTERY_CAPACITY%"
		fi
	fi
}

loadOutput() {
	LOAD_ONE=`cat /proc/loadavg | cut -d" " -f 1`
	LOAD_FIVE=`cat /proc/loadavg | cut -d" " -f 2`
	LOAD_FIFTEEN=`cat /proc/loadavg | cut -d" " -f 3`

	LOAD_OUTPUT="$LOAD_ONE / $LOAD_FIVE / $LOAD_FIFTEEN"
}

storeSportsNews() {
	NEWS=$1
	SPORT=$2
	MAX_LINES=$3

	if [[ -z "$NEWS" ]]
	then
		return 1
	fi

	grep -Fxq "$NEWS" /tmp/$SPORT.txt

	if [ $? -eq 1 ]
	then
		echo "$NEWS" >> /tmp/$SPORT.txt
		tail -n$MAX_LINES /tmp/$SPORT.txt > /tmp/$SPORT.txt.tmp
		mv /tmp/$SPORT.txt.tmp /tmp/$SPORT.txt
	fi
}

timeOutput() {
	TIME_OUTPUT=`date +"%-l:%M%P"`
}

dateOutput() {
	DATE_OUTPUT=`date +"%A, %B --"`
	DATE=`date +%-d`

	DATE_OUTPUT=`sed -e s/--/$DATE/ <<< "$DATE_OUTPUT"`
}

while :; do
	initialize $@

	batteryOutput
	dateOutput
	loadOutput
	timeOutput

	echo -n $LOAD_OUTPUT
	echo -n "$SEPARATOR"

	if [ "$BATTERY_OUTPUT" != "" ]
	then
		echo -n $BATTERY_OUTPUT
		echo -n "$SEPARATOR"
	fi

	echo -n $DATE_OUTPUT
	echo -n "$SEPARATOR"
	echo -n $TIME_OUTPUT
	echo " "

	sleep $DELAY
done

#!/bin/bash

initialize() {
	DEFAULT_DELAY=15

	SEPARATOR="  .:.  "
	DELAY=$([ "$1" != "" ] && echo $1 || echo $DEFAULT_DELAY)
}

baseballOutput() {
	BASEBALL_OUTPUT=`curl --silent "https://www.nbcsports.com/edge/api/player_news?sort=-created&page%5Blimit%5D=1&page%5Boffset%5D=0&filter%5Bleague.meta.drupal_internal__id%5D=1" | jq -r '.data[0].attributes.headline'`
}

basketballOutput() {
	BASKETBALL_OUTPUT=`curl --silent "https://www.nbcsports.com/edge/api/player_news?sort=-created&page%5Blimit%5D=1&page%5Boffset%5D=0&filter%5Bleague.meta.drupal_internal__id%5D=11" | jq -r '.data[0].attributes.headline'`
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

footballOutput() {
	FOOTBALL_OUTPUT=`curl --silent "https://www.nbcsports.com/edge/api/player_news?sort=-created&page%5Blimit%5D=1&page%5Boffset%5D=0&filter%5Bleague.meta.drupal_internal__id%5D=21" | jq -r '.data[0].attributes.headline'`
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

	baseballOutput
	basketballOutput
	batteryOutput
	dateOutput
	footballOutput
	loadOutput
	timeOutput

	if [ "$BASEBALL_OUTPUT" != "" ]
	then
		echo -n $BASEBALL_OUTPUT
		echo -n "$SEPARATOR"
	fi

	if [ "$BASKETBALL_OUTPUT" != "" ]
	then
		echo -n $BASKETBALL_OUTPUT
		echo -n "$SEPARATOR"
	fi

	if [ "$FOOTBALL_OUTPUT" != "" ]
	then
		echo -n $FOOTBALL_OUTPUT
		echo -n "$SEPARATOR"
	fi

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

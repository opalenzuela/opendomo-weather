#!/bin/sh
#desc:Configure weather station
#package:wundstation
#type:local

CFGFILE="/etc/opendomo/wundstation.conf"

if test -z "$1"; then
	if test -f "$CFGFILE"; then
		. $CFGFILE
	else
		STATION="BCN"
	fi
else
	STATION="$1"
	echo "STATION=$STATION" > $CFGFILE
	if /usr/local/opendomo/services/syscript/updateWeatherStation.sh; then
		echo "#INFO:Weather station updated"
	else
		echo "#WARN:Data couldn't be retrieved" 
	fi
fi

echo "#> Configure weather station"
echo "form:configureWeatherStation.sh"
echo "	station	Station code	text	$STATION"
echo
echo "#INFO: This package uses the [Weather Underground] API or resources"
echo "#URL:http://www.wunderground.com/"
echo

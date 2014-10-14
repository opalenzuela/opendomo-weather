#!/bin/sh
#desc:Configure weather station
#package:odweather
#type:local

DEVNAME="odweather"
CFGFILE="/etc/opendomo/$DEVNAME.conf"

STATIONLIST="/etc/opendomo/weatherstations.lst"

if test -f $STATIONLIST
then
	for s in `cat $STATIONLIST`
	do
		STATIONS="$STATIONS,$s"
	done
	RECONFIGURE=0
else
	echo "#WARN Geolocation was disabled. Please, reconfigure your system"
	RECONFIGURE=1
	STATIONS="BCN:Barcelona,ICOMUNID113:Madrid,ICOMUNID145:Valencia"
fi


if ! test -z "$1"; then
	# Parameters specified: saving config
	echo "STATION='$1'" > $CFGFILE
	echo "APIKEY='$2'" >> $CFGFILE

	if /usr/local/opendomo/services/syscript/updateWeatherStation.sh; then
		echo "#INFO:Weather station updated"
	else
		echo "#WARN:Data couldn't be retrieved" 
	fi
fi

if test -f $CFGFILE;
then
	source $CFGFILE
fi

echo "#> Configure weather station"
echo "form:configureWeatherStation.sh"
echo "	station	Station code	list[$STATIONS]	$STATION"
echo "	apikey	WeatherUnderground API key 	text	$APIKEY"
if test $RECONFIGURE -eq 1
then
	echo "actions:"
	echo "	wizFirstConfigurationStep1.sh	Reconfigure system"
fi
echo
echo "#INFO: This package uses the [Weather Underground] API or resources"
echo "#URL:http://www.wunderground.com/?apiref=62746aab6951fe52"
echo

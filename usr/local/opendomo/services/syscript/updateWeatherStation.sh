#!/bin/sh
#desc:Update weather station
#type:local
#package:odweather

DEVNAME="odweather"
CFGFILE="/etc/opendomo/$DEVNAME.conf"
LOCALFILE="/var/opendomo/tmp/$DEVNAME.tmp"
DATADIR="/var/opendomo/control/$DEVNAME"
CONFDIR="/etc/opendomo/control/$DEVNAME"
GEOFILE="/etc/opendomo/geo.conf"
STATIONLIST="/etc/opendomo/weatherstations.lst"

#If $DATADIR does not exist, we create it
test -d $DATADIR || mkdir -p $DATADIR

#If $CONFDIR does not exist, we create it and configure all the ports
if ! test -d $CONFDIR; then
	mkdir -p $CONFDIR

	echo "way=in" > $CONFDIR/temp.info
	echo "status=enabled" >> $CONFDIR/temp.info
	echo "name='Outside temperature'" >> $CONFDIR/temp.info
	echo "tags='climate'" >> $CONFDIR/temp.info
	echo "units='ºC'" >> $CONFDIR/temp.info
	echo "type='analog'" >> $CONFDIR/temp.info

	echo "way=in" > $CONFDIR/pressure.info
	echo "status=enabled" >> $CONFDIR/pressure.info
	echo "name='Atmospheric pressure'" >> $CONFDIR/pressure.info
	echo "tags='climate'" >> $CONFDIR/pressure.info
	echo "units='mb'" >> $CONFDIR/pressure.info
	echo "type='analog'" >> $CONFDIR/pressure.info

	echo "way=in" > $CONFDIR/wind.info
	echo "status=enabled" >> $CONFDIR/wind.info
	echo "name='Wind speed'" >> $CONFDIR/wind.info
	echo "tags='climate'" >> $CONFDIR/wind.info
	echo "units='mph'" >> $CONFDIR/wind.info
	echo "type='analog'" >> $CONFDIR/wind.info			

	echo "way=in" > $CONFDIR/humidity.info
	echo "status=enabled" >> $CONFDIR/humidity.info
	echo "name='Humidity'" >> $CONFDIR/humidity.info
	echo "tags='climate'" >> $CONFDIR/humidity.info
	echo "units='%'" >> $CONFDIR/humidity.info
	echo "type='analog'" >> $CONFDIR/humidity.info	

	echo "way=in" > $CONFDIR/description.info
	echo "status=enabled" >> $CONFDIR/description.info
	echo "name='Description'" >> $CONFDIR/description.info
	echo "tags='climate'" >> $CONFDIR/description.info
	echo "units='%'" >> $CONFDIR/description.info
	echo "type='text'" >> $CONFDIR/description.info				
fi
#Prerequisites end

# Case 1: we don't have geolocation nor configuration, we abort (it requires manual config)
if ! test -f "$GEOFILE" && ! test -f "$CFGFILE"
then
	echo "ERROR: No geolocation information found"
	exit
fi

# Case 2: we have geolocation but no configuration file
if ! test -f "$CFGFILE"
then
	echo "No configuration file found. Autoconfiguring..."
	source $GEOFILE
	URL="http://api.wunderground.com/auto/wui/geo/GeoLookupXML/index.xml"
	echo "URL: $URL"
	if wget --no-check-certificate -q "$URL?query=$latitude,$longitude" -O $LOCALFILE
	then
		grep '<icao>' $LOCALFILE   | cut -f2 -d'<' | cut -f2 -d'>' > $STATIONLIST
		STATION=`head -n1 $STATIONLIST`
		echo "STATION=$STATION" > $CFGFILE
		echo "Autoconfigured to $STATION"
		echo
	else
		echo "Error: impossible to locate nearest station"
		exit 
	fi
fi
source $CFGFILE

# Case 3: we have geolocation and API key
if ! test -z "$APIKEY"
then
	echo "Using API key $APIKEY ..."
	URL="http://api.wunderground.com/api/$APIKEY/conditions/q/$STATION.xml"
	if wget --no-check-certificate $URL -O $LOCALFILE
	then
		if test -f "$LOCALFILE"; then
			t=`grep temp_c $LOCALFILE | sed 's/[^0-9.]//g'`
			p=`grep pressure_mb $LOCALFILE | sed 's/[^0-9.]//g'`
			w=`grep wind_mph $LOCALFILE | sed 's/[^0-9.]//g'`
			h=`grep relative_humidity $LOCALFILE | sed 's/[^0-9.]//g'`
			d=`grep "<icon>" $LOCALFILE | cut -f2 -d'>' | cut -f1 -d'<'`
			
			
			H=`date +%H`
			DATE=`date +%s`
			rm $LOCALFILE

			if test -z "$p" || test "$p" = "0"; then
				# Error
				exit 1
			fi
		fi
	else
		rm $DATADIR/*
	fi
else
# Case 4: we have no geolocation nor API key
	URL="http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=$STATION"
	if wget --no-check-certificate $URL -O $LOCALFILE
	then
		if test -f "$LOCALFILE"; then
			t=`grep temp_c $LOCALFILE | sed 's/[^0-9.]//g'`
			p=`grep pressure_mb $LOCALFILE | sed 's/[^0-9.]//g'`
			w=`grep wind_mph $LOCALFILE | sed 's/[^0-9.]//g'`
			h=`grep relative_humidity $LOCALFILE | sed 's/[^0-9.]//g'`
			d=`grep "<icon>" $LOCALFILE | cut -f2 -d'>' | cut -f1 -d'<'`
			
			H=`date +%H`
			DATE=`date +%s`
			rm $LOCALFILE

			if test -z "$p" || test "$p" = "0"; then
				# Error
				exit 1
			fi
		fi
	else
		rm $DATADIR/*
	fi
fi

# Triggering events
old_t=`cat $DATADIR/temp`
test "$old_t" == "$t" || test "$t" -lt 5 && test "$old_t" -gt 5 && logevent "warnfreezing" $DEVNAME "Approaching freezing temperature"
test "$old_t" == "$t" || test "$t" -lt 1 && test "$old_t" -gt 1 && logevent "freezing" $DEVNAME "Entering freezing temperature"
old_d=`cat $DATADIR/description`
test "$old_d" == "$d" || logevent $d $DEVNAME "Weather changing to [$d]"


# Saving data
echo "$t" > $DATADIR/temp
echo "$p" > $DATADIR/pressure
echo "$w" > $DATADIR/wind
echo "$h" > $DATADIR/humidity
echo "$d" > $DATADIR/description

echo "Entering $DATADIR ..."
cd $DATADIR
test -d /var/www/data || mkdir /var/www/data
test -f /var/www/data/$DEVNAME.odauto && rm /var/www/data/$DEVNAME.odauto
for i in *
do
	echo " processing $i ... "
	echo -n "{\"Name\":\"$i\",\"Type\":\"AI\",\"Tag\":\"climate\",\"Value\":\"`cat $i`\",\"Id\":\"$DEVNAME/$i\"}," >> /var/www/data/$DEVNAME.odauto
done
echo "DONE"
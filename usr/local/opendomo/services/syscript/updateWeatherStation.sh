#!/bin/sh
#desc:Update weather station
#type:local
#package:wundstation

CFGFILE="/etc/opendomo/wundstation.conf"
LOCALFILE="/var/opendomo/tmp/wundstation.tmp"
URL="http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml"
DATADIR="/var/opendomo/control/wundstation"
CONFDIR="/etc/opendomo/control/wundstation"


if test -f "$CFGFILE"; then
	. $CFGFILE
	if wget --no-check-certificate -q $URL?query=$STATION -O $LOCALFILE; then
		mkdir -p $DATADIR
		if ! test -d $CONFDIR; then
			mkdir -p $CONFDIR

			echo "way=in" > $CONFDIR/temp.info
			echo "status=enabled" >> $CONFDIR/temp.info
			echo "name='Outside temperature'" >> $CONFDIR/temp.info
			echo "tags='climate'" >> $CONFDIR/temp.info
			echo "units='�C'" >> $CONFDIR/temp.info
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

		if test -f "$LOCALFILE"; then
			t=`grep temp_c $LOCALFILE | sed 's/[^0-9.]//g'`
			p=`grep pressure_mb $LOCALFILE | sed 's/[^0-9.]//g'`
			w=`grep wind_mph $LOCALFILE | sed 's/[^0-9.]//g'`
			h=`grep relative_humidity $LOCALFILE | sed 's/[^0-9.]//g'`
			d=`grep "<weather>" $LOCALFILE | cut -f2 -d'>' | cut -f1 -d'<'`
			
			H=`date +%H`
			DATE=`date +%s`
			rm $LOCALFILE

			if test -z "$p" || test "$p" = "0"; then
				# Error
				exit 1
			fi

			echo "$t" > $DATADIR/temp
			echo "$p" > $DATADIR/pressure
			echo "$w" > $DATADIR/wind
			echo "$h" > $DATADIR/humidity
			echo "$d" > $DATADIR/description			
		fi
	else
		rm $DATADIR/*
	fi
fi


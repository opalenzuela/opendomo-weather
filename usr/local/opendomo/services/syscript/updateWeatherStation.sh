#!/bin/sh
#desc:Update weather station
#type:local
#package:wundstation

CFGFILE="/etc/opendomo/wundstation.conf"
LOCALFILE="/var/opendomo/tmp/wundstation.tmp"
URL="http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml"
DATADIR="/var/opendomo/control/wundstation"
CONFDIR="/etc/opendomo/control/wundstation"
STATSDIR="/var/opendomo/log/stats"

if test -f "$CFGFILE"; then
	. $CFGFILE
	if wget -q $URL?query=$STATION -O $LOCALFILE; then
		mkdir -p $DATADIR
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
		fi

		if test -f "$LOCALFILE"; then
			t=`grep temp_c $LOCALFILE | sed 's/[^0-9.]//g'`
			p=`grep pressure_mb $LOCALFILE | sed 's/[^0-9.]//g'`
			H=`date +%H`
			DATE=`date +%s`
			rm $LOCALFILE

			if test -z "$p" || test "$p" = "0"; then
				# Error
				exit 1
			fi

			echo "$t" > $DATADIR/temp
			echo "$p" > $DATADIR/pressure
			echo "$DATE $t" >> $STATSDIR/wundstation-temp.h$H
			echo "$DATE $p" >> $STATSDIR/wundstation-pressure.h$H		
		fi
	else
		rm $DATADIR/*
	fi
fi


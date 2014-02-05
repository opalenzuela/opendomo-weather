#!/bin/sh
VERSION=`date '+%Y%m%d'`
USR="--owner 1000 --group 1000 --same-permissions "
EXCLUDE=" --exclude '*~' --exclude .svn "
PKGID="odweather"

rm -fr pkg/*.tar.gz
tar vcfz ./pkg/$PKGID-$VERSION.tar.gz usr var $USR $EXCLUDE



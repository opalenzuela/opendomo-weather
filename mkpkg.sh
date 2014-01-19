#!/bin/sh
VERSION=`date '+%Y%m%d'`
ARCH=noarch
USR="--owner 1000 --group 1000 --same-permissions "
EXCLUDE=" --exclude '*~' --exclude .svn "
PKGNAME="odweather"

rm -fr pkg/*.tar.gz
tar vcfz ./pkg/$PKGNAME-$VERSION.od.$ARCH.tar.gz usr var $USR $EXCLUDE



#!/bin/sh
PKGID="odweather"
tar cvfz $PKGID-`date '+%Y%m%d'`.tar.gz --exclude .svn  usr var 


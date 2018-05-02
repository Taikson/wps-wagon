#!/bin/sh
killall sleep 2>/dev/null
killall bully 2>/dev/null
killall pixiewps 2>/dev/null
killall nslookup 2>/dev/null
killall iwinfo 2>/dev/null
killall exe 2>/dev/null
killall query_date.sh 2>/dev/null
killall udhcpc 2>/dev/null
. ./init_custom.sh
. ./settings.sh
killall watch.sh 2>/dev/null
./services.sh for_scan 2>/dev/null
sleep 1
if [ "$1" == "stop" ];then
	echo Stopped launcher, watch
	exit
fi
./watch.sh $PHY_INDEX_WPS &



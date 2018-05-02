#!/bin/sh
. ./settings.sh
. ./common.sh
DELAY=3600
FORCE=$1

if [ -f /tmp/ddns_update ];then
	DIFF=$(expr $(date +%s) - $(cat /tmp/ddns_update))
else
	echo Skipping normal update
	DIFF=0		
fi

if ([ $DIFF -gt $DELAY ]||[ "$FORCE" == "force" ])then

	date +%s >/tmp/ddns_update
	killall wget
	#wget  -O - -T30 $AFRAID_DNS >/tmp/ddns_log &
	wget 8.8.8.8 &
	wait_for wget 30
	killall set_upnpc.sh
	killall upnpc
	./set_upnpc.sh > /tmp/upnpc_log &
fi

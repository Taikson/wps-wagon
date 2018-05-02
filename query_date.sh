#!/bin/sh

. ./settings.sh
. ./wait_for.sh
#/etc/init.d/sysntpd stop 2>/dev/null
#sleep 1

if [ -f saved_date.txt ];then
	SAVED_DATE=$(cat saved_date.txt)
	if [ $SAVED_DATE -gt $(date +%s) ];then
		echo Saved date is newer than current. Updating
		date -s @$SAVED_DATE
	fi
fi


PEERS=$PEERS_NTPD_INET
if [ "$1" == "local" ];then
	PEERS=$PEERS_NTPD_LOCAL

fi
for PEER in $PEERS;do
	echo 200 > /tmp/forced_ntpd_result
	$(ntpd -n -d -p $PEER -q;echo $? > /tmp/forced_ntpd_result)  &
	wait_for ntpd 60
	killall ntpd 2>/dev/null
	RES=$(cat /tmp/forced_ntpd_result)
	
	if [ "$RES" == "0" ];then
		echo Saving date on disk
		date +%s > saved_date.txt 
		break
	fi

done
cat /tmp/forced_ntpd_result

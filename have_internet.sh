#!/bin/sh
. ./wait_for.sh
echo 0 >/tmp/nsresult
killall nslookup 2>/dev/null
nslookup google.es 8.8.8.8 2>/dev/null|grep "Name:" |wc -l >/tmp/nsresult &
wait_for nslookup 15 2>/dev/null 1>/dev/null
RES=$(cat /tmp/nsresult)
if [ "$RES" == "" ];then
	echo 0
else

	echo $RES
fi






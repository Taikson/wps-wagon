#!/bin/sh
. ./settings.sh
PHYN=$1
KLINE=$2

./services.sh for_scan

echo Command try internet :: $PHYN $KLINE
./wireless_cfg.sh recycle
./wireless_cfg.sh $PHYN wan sta $KLINE
./set_my_bridge.sh

wifi
sleep 5
echo Configured. Trying DHCP for $WAIT_DHCP sec
WAIT=0
HAVEINET=0
while ([ $WAIT -lt $WAIT_DHCP ]&&[ $HAVEINET -eq 0 ]);do
	sleep $WAIT_DHCP_ROUND
	HAVEINET=$(. ./have_internet.sh)
	echo -ne \\r Scan inet: $HAVEINET  $WAIT / $WAIT_DHCP"       "
	WAIT=$(expr $WAIT + $WAIT_DHCP_ROUND)
done

if [ $HAVEINET -le 0 ];then
	echo No DHCP, trying default static ips	
	killall udhcpc
	for CIP in $FALLBACK_WAN_IPS;do
		IP=$(echo $CIP|cut -d ";" -f1)
		GW=$(echo $CIP|cut -d ";" -f2)
		ifconfig wlan$PHYN $IP up
		sleep 1
		route del default
		route add default gw $GW
		sleep 5
		HAVEINET=$(. ./have_internet.sh) 
		if [ $HAVEINET -gt 0 ];then
			break
		fi
	done
fi

if [ $HAVEINET -eq 0 ];then
	rm /tmp/trusted_wan_params
fi


echo "HAVEINET="$HAVEINET 

#!/bin/sh

. ./settings.sh

try_upnpc(){
	ARGS=$1
	RETRY=$2
	AC=0
	RES=999
	while ([ $AC -lt $RETRY ]&&[ $RES -ne 0 ]);do
		upnpc $ARGS
		RES=$?
		sleep 3	
		AC=$(expr $AC + 1)
	done  

}


LAN=$(try_upnpc "-l" 15|grep -m1 "Local LAN"|cut -d ":" -f2|tr -d " ")

RES=$?
if ([ "$LAN" != "" ]&&[ $RES -ne 1 ]);then
	for RULE in $UPNP_CONFIG;do	
		
		try_upnpc "-d $(echo $RULE|cut -d";" -f2,3|tr ";" " ")" 10
		sleep 3
		try_upnpc "-e 'upnp'  -a $LAN  $(echo $RULE|tr ";" " ") " 10
		echo RES $?
		sleep 3
	done

else
	echo No uPnP available, exiting


fi

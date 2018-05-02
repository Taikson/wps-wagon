#!/bin/sh
. ./settings.sh

notify_gw(){
        STAT=$2
        PEER=$1
	ERROR=1
	TRY=0
	PORT=10000
	if [ "$PEER" != "" ];then
		while ([ $ERROR -ne 0 ]&&[ $TRY -lt 5 ]);do
			IPN=$(ifconfig br-lan|grep "inet addr"|cut -d ":" -f2|cut -d" " -f1)
			PKT="gw:$STAT:$IPN"
			if [ $(which socat|wc -l) -gt 0 ];then
				echo $PKT|socat - TCP4:$PEER:$PORT
			else

	        		echo $PKT|nc -w 3  $PEER $PORT
			fi
			ERROR=$?
			TRY=$(expr $TRY + 1)
			sleep $TRY
		done
	fi
}

killall wget
killall nslookup
killall upnpc
killall set_upnpc.sh
SELF=$(ps -w |grep -v grep|grep check_conn.sh|wc -l)




if [ $SELF -gt 3 ];then
	echo -n "*" >>/tmp/check_conn_log
	exit
fi


WATCH=$(ps -w|grep watch.sh| grep -v grep|wc -l)
if [ $WATCH -gt 0 ];then
    	notify_gw $GWNOTIFY 0
	echo -n "." >>/tmp/check_conn_log
	exit
fi

HAVE=$(. ./have_internet.sh)
if [ $HAVE -le 0 ];then
	if [ -f /tmp/trusted_wan_params ];then
		sleep 10
		. ./try_internet.sh $(cat /tmp/trusted_wan_params)
		sleep 10
		HAVE=$(. ./have_internet.sh)

		if [ $HAVE -le 0 ];then
			notify_gw $GWNOTIFY 0
			rm /tmp/trusted_wan_params
	                echo -n "h" >>/tmp/check_conn_log
	                ./launcher.sh &
		else
			notify_gw $GWNOTIFY 1
		        ./services.sh "for_internet"
        		./ddns.sh &
			echo -n "H" >>/tmp/check_conn_log
			
		fi
		
	else
		 notify_gw $GWNOTIFY 0
	        echo -n "#" >>/tmp/check_conn_log
       		./launcher.sh &

	fi

else
	 notify_gw $GWNOTIFY 1
	./services.sh "for_internet"
	./ddns.sh &
	echo -n "1" >>/tmp/check_conn_log
fi

#!/bin/sh


MODE=$1

check_running(){
        ps -w|grep -v grep|grep -v $$" root"|grep $1|wc -l
}

issue_services(){
        for SRV in $(echo $1|tr "," " ");do
		SRVNAME=$(echo $SRV|cut -d ":" -f1)
		SRVPROC=$(echo $SRV|cut -d ":" -f2)
		if [ "$SRVPROC" == "" ];then
			SRVPROC=$SRVNAME
		fi
                if ([ $(check_running $SRVPROC) -lt 1 ]||[ "$2" == "stop" ]);then
                        /etc/init.d/$SRVNAME $2 2>/dev/null
                fi
        done

}


SRVS_START="autossh,sysntpd:ntpd"
SRVS_STOP="autossh,sysntpd,udhcpd,wpa:wpa_supplicant"
if [ "$MODE" == "for_scan" ];then
        echo "Stopping services for scan"
        issue_services $SRVS_STOP stop
        killall bully
        killall pixiewps


fi
if [ "$MODE" == "for_internet" ];then
        echo Starting services for Internet
	issue_services $SRVS_START reload
fi

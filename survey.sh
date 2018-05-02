killall iwinfo 2>/dev/null
iwinfo $1 scan >/tmp/survey
NEXT=1
MAC=""
SIG=""
ESSID=""
ENC=""
CHN=""
NMAC=""
while read -r L;do
	if ([ $NEXT -eq 1 ]);then
		echo $SIG"#"$NMAC"#"$CHN"#"$ENC"#"$ESSID 
		NEXT=0
	fi
	if [ $(echo $L|grep "Address:"|wc -l) -gt 0 ];then
		NMAC=$(echo $L|cut -d " " -f5)
		
	fi
        if [ $(echo $L|grep "ESSID:"|wc -l) -gt 0 ];then
		ESSID=$(echo $L|cut -d":" -f2,3,4|sed 's/^ *//g')
	fi
	if [ $(echo $L|grep "Channel:"|wc -l) -gt 0 ];then 
		CHN=$(echo $L|cut -d ":" -f3|tr -d " ")	
	fi
	if [ $(echo $L|grep "Quality:"|wc -l) -gt 0 ];then
		SIG=$(echo $L|cut -d ":" -f3|tr -d " "|cut -d"/" -f1)
	fi
	if [ $(echo $L|grep "Encryption:"|wc -l) -gt 0 ];then
		NEXT=1
		ENC=$(echo $L|cut -d ":" -f2|tr -d " ")
		if [ $(echo $ENC|grep -i mixed|wc -l) -gt 0 ];then
			ENC=psk2
			continue
		fi
                if [ $(echo $ENC|grep -i wpa2|wc -l) -gt 0 ];then
                        ENC=psk2
			continue
                fi
                if [ $(echo $ENC|grep -i wpa|wc -l) -gt 0 ];then
                        ENC=psk
                        continue
                fi
                if [ $(echo $ENC|grep -i wep|wc -l) -gt 0 ];then
                        ENC=wep
                        continue
                fi
                if [ $(echo $ENC|grep -i none|wc -l) -gt 0 ];then
                        ENC=none
                        continue
                fi

		

		
	fi
done < /tmp/survey
rm /tmp/survey




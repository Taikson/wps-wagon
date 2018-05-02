#!/bin/sh

NPHY=$1
NET=$2
MODE=$3
PARAMS=$4

echo ::::Wireless CFG: $NPHY  $NET $MODE $PARAMS

W="wireless."          
I="@wifi-iface["$NPHY"]"
R="radio"$NPHY

CMD="spec"


if [ "$NPHY" == "recycle" ];then
        uci revert wireless
        wifi detect >/etc/config/wireless
        wifi
	exit
fi



if ([ "$NET" != "reset" ]);then

	BSSID=$(echo $PARAMS|cut -d "~" -f1)
	ENC=$(echo $PARAMS|cut -d "~" -f2)
	ESSID=$(echo $PARAMS|cut -d "~" -f3)
	KEY=$(echo $PARAMS|cut -d "~" -f4)
	CMD="normal"
	
	
	uci set "$W$R".channel='auto'
	uci set "$W$R".htmode='HT20'
	uci set "$W$R".disabled='0'
	uci set "$W$R".hwmode='11n'

	uci set "$W$I".network="$NET"
	uci set "$W$I".device="radio$NPHY"

fi

if [ "$NET" == "reset" ];then
	uci delete "$W$R" 2>/dev/null
	uci delete "$W$I" 2>/dev/null      
fi
if [ "$CMD" == "normal" ];then	

	if [ $(echo $MODE|grep 'wds'|wc -l) -gt 0 ];then
		uci set "$W$I".wds=1
	else
		uci set "$W$I".wds=0
	fi
	MODE=$(echo $MODE|sed 's/-wds//g')
	uci set "$W$I".mode=$MODE
	uci set "$W$I".ssid="$ESSID"
	uci set "$W$I".encryption="$ENC"
	uci set "$W$I".key="$KEY"
fi


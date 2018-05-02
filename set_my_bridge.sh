#!/bin/sh

. ./settings.sh

if [ "$PHY_INDEX_BRIDGE" != "" ];then
	BLINE=""NA~"$BRIDGE_ENC"~"$BRIDGE_ESSID"~"$BRIDGE_KEY"

        echo $PHY_INDEX_BRIDGE wlan $BRIDGE_MODE "$BLINE"
        . ./wireless_cfg.sh $PHY_INDEX_BRIDGE wlan $BRIDGE_MODE "$BLINE"
        wifi
else
	echo No bridge interface was set
fi


#!/bin/sh
echo ""
echo ""
echo "***************WPS WATCH INITIAL CONFIG*****************"
echo "Config manually:"
echo "     -include AP interface in lan network in /etc/config network"
echo "         example: "		
echo "          config interface 'lan'"
echo "	             option ifname 'eth0.1 wlan0'"
echo "      -include wlan client interface as wan dhcp network in /etc/config network"
echo "         example:"
echo "          config interface 'wan'"
echo "               option ifname 'wlan1'"
echo "               option proto 'dhcp'"

echo "      -put this router IP as gateway on udhcpd.conf file on this directory"
echo "	        example:  opt     router  192.168.250.242"



rm /etc/config/wireless
touch /tmp/wireless_cfg

ln -s /tmp/wireless_cfg /etc/config/wireless
wifi detect > /etc/config/wireless

mkdir /etc/crontabs

cp udhcpd.conf /etc/udhcpd.conf


echo "*/1  * * * * cd $(pwd) && ./check_conn.sh #"  >>/etc/crontabs/root
echo "#" >>/etc/crontabs/root
/etc/init.d/cron start
/etc/init.d/cron enable

chmod 777 *.sh
. ./settings.sh


BLINE=""NA~"$BRIDGE_ENC"~"$BRIDGE_ESSID"~"$BRIDGE_KEY"
echo "$PHY_INDEX_BRIDGE lan $BRIDGE_MODE "$BLINE""
. ./wireless_cfg.sh $PHY_INDEX_BRIDGE lan $BRIDGE_MODE "$BLINE"
wifi


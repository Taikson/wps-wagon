#!/bin/sh
IF=$1

FR=$(iwinfo $IF info|grep Quality|tr -d " "|cut -d ":" -f3)

SIGNAL=$(echo $FR|cut -d "/" -f1)
TOTAL=$(echo $FR|cut -d "/" -f2)



if [ $SIGNAL -ne $SIGNAL 2> /dev/null ];then
	SIGNAL=0

fi

ABS=$(expr $SIGNAL"00" / 70 )
echo $ABS

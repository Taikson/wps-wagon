ifconfig $1 down
iw dev $1 set type $2
ifconfig $1 up

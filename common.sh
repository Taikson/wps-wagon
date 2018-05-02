wait_for(){
        PROC=$1
        WAIT=0
        WTOTAL=$2
        while [ $WAIT -lt $WTOTAL ];do
                sleep 1
                PRESENT=$(ps -w|grep $PROC|grep -v grep|tr -d " "|wc -l)
                if [ $PRESENT -eq 0 ];then
                  echo "$PROC Not preset. Continue."
                 break
                fi
                WAIT=$(expr $WAIT + 1)
                echo -ne \\r $WAIT / $WTOTAL"         "
        done
}


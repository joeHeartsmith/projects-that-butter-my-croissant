#!/usr/local/bin/bash

IFACE=trunk0
PREFIX_LEN=60
ADDR_STORE=/var/db/ldrstore-trunk0
DOWNSTREAM_RTR_ADDR=192.168.11.10
DOWNSTREAM_RTR_PORT=5000

echo "/60" > $ADDR_STORE

while true
do
    LAST_ADDR=$(cat $ADDR_STORE)
    ADDR_1=$(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){3}')
    ADDR_2=$(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){3}[0-9a-f]{4}' | cut -d ':' -f 4)
    ADDR_2N=$(echo $(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){3}[0-9a-f]{4}' | cut -d ':' -f 4 | tr '[:lower:]' '[:upper:]') 1 | dc -e '16o16i?+p' | tr '[:upper:]' '[:lower:]')

    ADDR_2N_2=$(echo $(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){3}[0-9a-f]{4}' | cut -d ':' -f 4 | tr '[:lower:]' '[:upper:]') 2 | dc -e '16o16i?+p' | tr '[:upper:]' '[:lower:]')
    ADDR_2N_3=$(echo $(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){3}[0-9a-f]{4}' | cut -d ':' -f 4 | tr '[:lower:]' '[:upper:]') 3 | dc -e '16o16i?+p' | tr '[:upper:]' '[:lower:]')
    ADDR_2N_5=$(echo $(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){3}[0-9a-f]{4}' | cut -d ':' -f 4 | tr '[:lower:]' '[:upper:]') 5 | dc -e '16o16i?+p' | tr '[:upper:]' '[:lower:]')
    ADDR_2N_8=$(echo $(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){3}[0-9a-f]{4}' | cut -d ':' -f 4 | tr '[:lower:]' '[:upper:]') 8 | dc -e '16o16i?+p' | tr '[:upper:]' '[:lower:]')
    ADDR_2N_P=$(echo $(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){3}[0-9a-f]{4}' | cut -d ':' -f 4 | tr '[:lower:]' '[:upper:]') 9 | dc -e '16o16i?+p' | tr '[:upper:]' '[:lower:]')

    CUR_ADDR=$(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){4}:1')"/$PREFIX_LEN"
    echo $CUR_ADDR > $ADDR_STORE

    if [ "$CUR_ADDR" == "$LAST_ADDR" ]; then
        sleep 2
    else
        sleep 2
        NEXTNET=${ADDR_1}${ADDR_2N}"::/64"
        NEXTNET_2=${ADDR_1}${ADDR_2N_2}"::/64"
        NEXTNET_3=${ADDR_1}${ADDR_2N_3}"::/64"
        NEXTNET_5=${ADDR_1}${ADDR_2N_5}"::/64"
        NEXTNET_8=${ADDR_1}${ADDR_2N_8}"::/64"
        NEXTNET_P=${ADDR_1}${ADDR_2N_P}"::/64"
        ROUTE_DEST=$(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | tail -n 1 | sed -e 's/^[[:space:]]*//' | cut -d ' ' -f 2 | sed 's/::1/::2/')
        VLTIME=$(ifconfig $IFACE inet6 | grep "prefixlen $PREFIX_LEN" | awk '{ print $8 }')

        route del $NEXTNET $ROUTE_DEST &> /dev/null
        route add $NEXTNET $ROUTE_DEST &> /dev/null

        route del $NEXTNET_2 $ROUTE_DEST &> /dev/null
        route add $NEXTNET_2 $ROUTE_DEST &> /dev/null
        route del $NEXTNET_3 $ROUTE_DEST &> /dev/null
        route add $NEXTNET_3 $ROUTE_DEST &> /dev/null
        route del $NEXTNET_5 $ROUTE_DEST &> /dev/null
        route add $NEXTNET_5 $ROUTE_DEST &> /dev/null
        route del $NEXTNET_8 $ROUTE_DEST &> /dev/null
        route add $NEXTNET_8 $ROUTE_DEST &> /dev/null
        route del $NEXTNET_P $ROUTE_DEST &> /dev/null
        route add $NEXTNET_P $ROUTE_DEST &> /dev/null

        exec 3>/dev/tcp/$DOWNSTREAM_RTR_ADDR/$DOWNSTREAM_RTR_PORT
        echo "$ADDR_1$ADDR_2::2/60;$ADDR_1$ADDR_2N::1/64;$ADDR_1$ADDR_2N_2::1/64;$ADDR_1$ADDR_2N_3::1/64;$ADDR_1$ADDR_2N_5::1/64;$ADDR_1$ADDR_2N_8::1/64;$ADDR_1$ADDR_2N_P::1/64;$VLTIME" 1>&3
    fi
    sleep 1
done

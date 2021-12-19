#!/bin/bash

EXT_IF=bond0
INT_IF=bond1.10
INT_IF_2=bond1.20
INT_IF_3=bond1.30
INT_IF_5=bond1.50
INT_IF_8=bond1.80
INT_IF_P=bond1.900
PREFIX_LEN=60
ULA_PFX="fd8d:6ff2"
ULA_ADDRESS=fd8d:6ff2:7bc:7b10:1::1

INT_UL_ADDR_2=fd8d:6ff2:7bc:7b12:1::1
INT_UL_ADDR_3=fd8d:6ff2:7bc:7b13:1::1
INT_UL_ADDR_5=fd8d:6ff2:7bc:7b15:1::1
INT_UL_ADDR_8=fd8d:6ff2:7bc:7b18:1::1
INT_UL_ADDR_P=fd8d:6ff2:7bc:7b19:1::1

INT_LL_ADDR=fd8d:6ff2:7bc:7b11:1::1

EXT_LL_ADDR=fe80::215:17ff:fe1c:33ba

INT_LL_ADDR_1=fe80::cabc:c8ff:fef5:3514
INT_LL_ADDR_2=fe80::cabc:c8ff:fef5:3514
INT_LL_ADDR_3=fe80::cabc:c8ff:fef5:3514
INT_LL_ADDR_5=fe80::cabc:c8ff:fef5:3514
INT_LL_ADDR_8=fe80::cabc:c8ff:fef5:3514
INT_LL_ADDR_P=fe80::cabc:c8ff:fef5:3514


ADDR_SRC_FILE=/opt/run/ifcfgaddr

ADDR_1=$(cat $ADDR_SRC_FILE | tail -n 1 | cut -d ';' -f 1)
ADDR_2=$(cat $ADDR_SRC_FILE | tail -n 1 | cut -d ';' -f 2)

ADDR_2_2=$(cat $ADDR_SRC_FILE | tail -n 1 | cut -d ';' -f 3)
ADDR_2_3=$(cat $ADDR_SRC_FILE | tail -n 1 | cut -d ';' -f 4)
ADDR_2_5=$(cat $ADDR_SRC_FILE | tail -n 1 | cut -d ';' -f 5)
ADDR_2_8=$(cat $ADDR_SRC_FILE | tail -n 1 | cut -d ';' -f 6)
ADDR_2_P=$(cat $ADDR_SRC_FILE | tail -n 1 | cut -d ';' -f 7)

INT_LAST_ADDR=$(cat $ADDR_SRC_FILE | tail -n 2 | head -n 1 | cut -d ';' -f 2)
#VALID_TIME=$(cat $ADDR_SRC_FILE | tail -n 1 | cut -d ';' -f 8)
VALID_TIME='forever'

LAST_ADDR_1=$(ifconfig $EXT_IF | grep "prefixlen $PREFIX_LEN" | tail -n 1 | egrep -o '([0-9a-f]{0,4}:){4}:2')"/$PREFIX_LEN"
LAST_ADDR_2=$(ifconfig $INT_IF | grep "prefixlen 64" | tail -n 1 | grep -v $ULA_PFX | egrep -o '([0-9a-f]{0,4}:){4}:1')"/64"

ip -6 address delete ::2/60 dev $EXT_IF &> /dev/null
ip -6 address delete 1::1/64 dev $INT_IF &> /dev/null

if [ "$ADDR_1" != "$LAST_ADDR_1" ]; then
    #ip -6 address delete $LAST_ADDR_1 dev $EXT_IF &> /dev/null
    ip -6 address flush dev $EXT_IF
    ip -6 address add $EXT_LL_ADDR/64 dev $EXT_IF
    ip -6 address add $ADDR_1 dev $EXT_IF valid_lft $VALID_TIME preferred_lft $VALID_TIME #&> /dev/null
    echo "UPDATE: Lifetime is $VALID_TIME"
else
    :
fi

if [ "$ADDR_2" != "$LAST_ADDR_2" ]; then
    #ip -6 address delete $LAST_ADDR_2 dev $INT_IF &> /dev/null
    #ip -6 address delete $INT_LAST_ADDR/64 dev $INT_IF &> /dev/null
    ip -6 address flush dev $INT_IF
    ip -6 address flush dev $INT_IF_2
    ip -6 address flush dev $INT_IF_3
    ip -6 address flush dev $INT_IF_5
    ip -6 address flush dev $INT_IF_8
    ip -6 address flush dev $INT_IF_P
    ip -6 address add $INT_LL_ADDR/80 dev $INT_IF
    ip -6 address add $INT_LL_ADDR_1/64 dev $INT_IF
    ip -6 address add $INT_LL_ADDR_2/64 dev $INT_IF_2
    ip -6 address add $INT_LL_ADDR_3/64 dev $INT_IF_3
    ip -6 address add $INT_LL_ADDR_5/64 dev $INT_IF_5
    ip -6 address add $INT_LL_ADDR_8/64 dev $INT_IF_8
    ip -6 address add $INT_LL_ADDR_P/64 dev $INT_IF_P

    ip -6 address add $INT_UL_ADDR_2/80 dev $INT_IF_2
    ip -6 address add $INT_UL_ADDR_3/80 dev $INT_IF_3
    ip -6 address add $INT_UL_ADDR_5/80 dev $INT_IF_5
    ip -6 address add $INT_UL_ADDR_8/80 dev $INT_IF_8
    ip -6 address add $INT_UL_ADDR_P/80 dev $INT_IF_P

#    ip -6 address add $ULA_ADDRESS/80 dev $INT_IF
    ip -6 address add $ADDR_2 dev $INT_IF valid_lft $VALID_TIME preferred_lft $VALID_TIME #&> /dev/null

    ip -6 address add $ADDR_2_2 dev $INT_IF_2 valid_lft $VALID_TIME preferred_lft $VALID_TIME #&> /dev/null
    ip -6 address add $ADDR_2_3 dev $INT_IF_3 valid_lft $VALID_TIME preferred_lft $VALID_TIME #&> /dev/null
    ip -6 address add $ADDR_2_5 dev $INT_IF_5 valid_lft $VALID_TIME preferred_lft $VALID_TIME #&> /dev/null
    ip -6 address add $ADDR_2_8 dev $INT_IF_8 valid_lft $VALID_TIME preferred_lft $VALID_TIME #&> /dev/null
    ip -6 address add $ADDR_2_P dev $INT_IF_P valid_lft $VALID_TIME preferred_lft $VALID_TIME #&> /dev/null


else
    :
fi

ip -6 address delete ::2/60 dev $EXT_IF &> /dev/null
ip -6 address delete 1::1/64 dev $INT_IF &> /dev/null
#    service radvd stop && sleep 60 && service radvd start


exit 0

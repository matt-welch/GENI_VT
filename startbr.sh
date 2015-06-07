#!/bin/bash
IF=eth0
BR=br0

echo "Creating ${BR} in $0"

IP_ADDR=`/sbin/ifconfig ${IF} | grep "inet addr" | tr -s ' ' | cut -d ' ' -f3 | cut -d ":" -f2`

NETMASK=`/sbin/ifconfig ${IF} | grep "inet addr" | tr -s ' ' | cut -d ":" -f4`

/sbin/brctl addbr ${BR}

/sbin/brctl addif ${BR} ${IF}

ifconfig ${IF} 0.0.0.0 promisc

ifconfig ${BR} ${IP_ADDR} netmask ${NETMASK} up

# this line may not be necessary in most cases
#route add default gw 192.168.83.168 $BR

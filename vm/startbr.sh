#!/bin/bash
# NOTE: if this is run when the interface is the ONLY interface, 
# you will lose your SSH connection when the interface goes down
IF=em0 # $(ifconfig | grep 192.168 -B 1 | head -n 1 | cut -d ' ' -f 1)
BR=br0

echo "Creating ${BR} in $0"

IP_ADDR=`/sbin/ifconfig ${IF} | grep "inet addr" | tr -s ' ' | cut -d ' ' -f3 | cut -d ":" -f2`
NETMASK=`/sbin/ifconfig ${IF} | grep "inet addr" | tr -s ' ' | cut -d ":" -f4`

/sbin/brctl addbr ${BR}
/sbin/brctl addif ${BR} ${IF}
ifconfig ${IF} 0.0.0.0 promisc
ifconfig ${BR} ${IP_ADDR} netmask ${NETMASK} up

# this line may not be necessary in most cases
route add default gw 192.168.42.1 $BR


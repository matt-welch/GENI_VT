#!/bin/sh
SWITCH=br0
if [ -n "$1" ];then
        /sbin/ifconfig $1 up
        sleep 1
    echo "Adding interface $1 to bridge $SWITCH"
        /sbin/brctl addif $SWITCH $1
        exit 0
else
        echo "Error: no interface specified"
        exit 1
fi


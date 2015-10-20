#!/bin/bash

if [ -n $1 ] ; then 
    IF=$1
    IP_ADDR="192.168.2.21/24"
    echo "Setting bridged interface $IF to $IP_ADDR"
    ifconfig $IF $IP_ADDR up 
fi

if [ -n $2 ] ; then 
    IF=$2
    IP_ADDR="192.168.3.21/24"
    echo "Setting physical interface $IF to $IP_ADDR"
    ifconfig $IF $IP_ADDR up 
fi

if [ -n $3 ] ; then 
    IF=$3
    IP_ADDR="192.168.4.21/24"
    echo "Setting virtual function interface $IF to $IP_ADDR"
    ifconfig $IF $IP_ADDR up 
fi

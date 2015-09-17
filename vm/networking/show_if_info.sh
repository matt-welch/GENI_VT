#!/bin/bash

IFS_LIST=$(ifconfig -a | grep "^[a-z]" | awk '{print $1}')

for IF in $IFS_LIST 
do
    if [ $IF != "lo" ] ; then 
        echo Interface $IF: 
        ethtool -i $IF | grep -e bus-info 
        ethtool -i $IF | grep -e driver
        ifconfig $IF
    fi
done

#IF=eth0
#ifconfig $IF | grep -i hwaddr -A 1
#ethtool -i $IF | grep -e driver -e bus-info 
#IF=eth1
#ifconfig $IF | grep -i hwaddr -A 1
#ethtool -i $IF | grep -e driver -e bus-info 
#IF=eth2
#ifconfig $IF | grep -i hwaddr -A 1
#ethtool -i $IF | grep -e driver -e bus-info 
#IF=rename5
#ifconfig $IF | grep -i hwaddr -A 1
#ethtool -i $IF | grep -e driver -e bus-info 

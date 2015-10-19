#!/bin/bash
IFACE=$(ifconfig | grep 192.168.2.3 -B 1 | grep Ethernet | awk '{print $1}')

route add -net 192.168.42.240/28 gw 192.168.2.1 $IFACE

route -vn 

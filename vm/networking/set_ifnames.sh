#!/bin/bash 
OLD=em0
NEW=eth0
ip link set $OLD name $NEW 
OLD=p258p1
NEW=eth10
ip link set $OLD name $NEW 
OLD=p258p2
NEW=eth11
ip link set $OLD name $NEW 


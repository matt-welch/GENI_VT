#!/bin/bash 
OLD=eth1
NEW=eth10
ifconfig $OLD down 
ip link set $OLD name $NEW 

OLD=eth4
NEW=eth11
ifconfig $OLD down 
ip link set $OLD name $NEW 

OLD=rename2
NEW=eth0
ifconfig $OLD down 
ip link set $OLD name $NEW 

OLD=eth8
NEW=eth1
ifconfig $OLD down 
ip link set $OLD name $NEW 
dhclient eth1


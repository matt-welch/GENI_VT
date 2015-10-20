#!/bin/bash 
function remove_iface(){
    IFACE=virbr0
    if [ -n $(ifconfig -a | grep $IFACE) ] ; then 
        ifconfig $IFACE down 
        brctl delbr $IFACE
    fi
}
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

# common to all systems
dhclient eth1
ifconfig eth10 192.168.2.3 up 
ifconfig eth11 192.168.3.3 up 

remove_iface

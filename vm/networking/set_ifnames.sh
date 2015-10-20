#!/bin/bash 
# remove virbr0

function remove_bridge(){
    BRIDGE=virbr0
    if [ -n "$(ifconfig -a | grep $BRIDGE)" ] ; then 
        ifconfig $BRIDGE down 
        brctl delbr $BRIDGE
    fi
}
function get_dhcp_ip() {
    IFACE=$1
    if [ -z $(ifconfig "$IFACE" | grep "inet ") ] ; then 
        dhclient $IFACE
    fi
    ifconfig $IFACE
}

remove_bridge

OLD=p2p1
NEW=eth10
ifconfig $OLD down 
ip link set $OLD name $NEW 
ifconfig $NEW 192.168.2.1 up 

OLD=p2p2
NEW=eth11
ifconfig $OLD down 
ip link set $OLD name $NEW 
ifconfig $NEW 192.168.3.1 up 

OLD=eth0
NEW=eth0
#ifconfig $OLD down 
#ip link set $OLD name $NEW 
get_dhcp_ip eth0


OLD=eth2
NEW=eth1
ifconfig $OLD down 
ip link set $OLD name $NEW 



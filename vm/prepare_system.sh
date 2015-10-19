#!/bin/bash
function remove_bridge(){
    BRIDGE=$1
    if [ -n "$(ifconfig -a | grep $BRIDGE)" ] ; then 
        ifconfig $BRIDGE down 
        brctl delbr $BRIDGE
    fi
}
function get_dhcp_ip() {
    IFACE=$1
    if [ -z "$(ifconfig $IFACE | grep "inet ")" ] ; then 
        dhclient $IFACE
    fi
    ifconfig $IFACE
}
function unbind() {
    CURRDRIVER=$(lspci -ks $1 | grep "Kernel driver in use" | cut -d ":" -f 2)    
    echo $CURRDRIVER
    if [ "$CURRDRIVER" != *"pci-stub"* ] ; then 
        ./unbind_driver.sh "$1"
    fi
}
## rename interfaces to standard names
#networking/set_ifnames.sh 

# disable docker and it's bridge
service docker stop 
# remove docker0 bridge
remove_bridge docker0
# remove virbr0 bridge
remove_bridge virbr0

# set up networking for VM
# enable an igbvf device for the VM control interface
networking/enable_vf_driver.sh 05:00.0 1
# bring up eth0 (host) 
get_dhcp_ip eth0 

# unbind the driver for eth0 (eth0-vf)
unbind "05:10.0"
# unbind the host driver for eth11 (passthrough)
unbind "03:00.1"

# NOTE hugepages are handled by the startvm_standard.sh script
USE_VFS="False" 
if [ $USE_VFS == "True" ] ; then 
    networking/enable_vf_driver.sh 03:00.1 1 
    unbind 04:10.1
fi

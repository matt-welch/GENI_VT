#!/bin/bash

# remove *.unbound files 
rm ./*.unbound

# rename interfaces to standard names
networking/set_ifnames.sh 

# disable docker and it's bridge
service docker stop 
ifconfig docker0 down 
brctl delbr docker0
ifconfig virbr0 down 
brctl delbr virbr0 

# set up networking for VM
# enable an igbvf device for the VM control interface
networking/enable_vf_driver.sh 08:00.1 1
# bring up eth1 (host) 
dhclient eth1 
# unbind the driver for eth0 (eth1-vf)
./unbind_driver.sh 09:10.1
# unbind the host driver for p258p1 
./unbind_driver.sh 04:00.0

# NOTE hugepages are handled by the startvm_standard.sh script
USE_VFS="False" 
if [ $USE_VFS == "True" ] ; then 
    networking/enable_vf_driver.sh 04:00.1 1 
    ./unbind_driver.sh 04:10.1
fi

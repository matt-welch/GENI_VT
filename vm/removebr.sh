#!/bin/bash

IF=eth0
BR=br0

ifconfig ${BR} down
brctl delif ${BR} ${IF}
brctl delbr ${BR}
dhclient ${IF}

echo "Current interface/bridge status"
ifconfig $IF
brctl show 


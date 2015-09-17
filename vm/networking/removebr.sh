#!/bin/bash

IF=em0
BR=br0

ifconfig ${BR} down
brctl delif ${BR} ${IF}
brctl delbr ${BR}
ifup $IF

echo "Current interface/bridge status"
ifconfig $IF
brctl show 


#!/bin/bash
function usage () {
    echo "$0 PCI_DEVICE"
    echo "Note: PCI device must be specified as Bus:Device.Function e.g. 08:00.1"
}

function unbindDevice () {
    echo "Unbinding device \"$DEVICE_BDF\" ($DEVICE_ID) from driver \"$DRIVER\" ..."
    
    TARGET1="/sys/bus/pci/drivers/pci-stub/new_id"
    TARGET2="/sys/bus/pci/drivers/${DRIVER}/unbind"
    TARGET3="/sys/bus/pci/drivers/pci-stub/bind"
    TARGET4="/sys/bus/pci/drivers/pci-stub/remove_id"
    
    echo "$DEVICE_ID" > $TARGET1
    echo "0000:${DEVICE_BDF}" > $TARGET2
    echo "0000:${DEVICE_BDF}" > $TARGET3
    echo "$DEVICE_ID" > $TARGET4
}

if [ -z "$1" ] ; then 
    usage
    exit
else
    # else, assume a valid B:D.f has been passed in
    DEVICE_BDF="$1"
fi
modprobe pci-stub 

DEVICE_INFO=$(lspci -ns "$DEVICE_BDF")
if [ -z "$DEVICE_INFO" ] ; then 
    echo "Error: Invalid device specified: $DEVICE_BDF"
    exit
fi

DEVICE_VENDOR=$(echo $DEVICE_INFO | cut -d ":" -f 3 | tr -d '[:space:]')
DEVICE_NUM=$(echo $DEVICE_INFO | cut -d ":" -f 4 | cut -d ' ' -f 1 )
DRIVER=$(lspci -ks $DEVICE_BDF | grep "Kernel driver" | cut -d ":" -f 2 | tr -d '[:space:]') 
DEVICE_ID="$DEVICE_VENDOR $DEVICE_NUM"

echo "$DEVICE_VENDOR $DEVICE_NUM $DRIVER pci-stub $DEVICE_BDF " >> ${DRIVER}.unbound

read -p "Are you sure you want to unbind device \"$DEVICE_BDF\" ($DEVICE_ID) from its driver \"$DRIVER\"? " -n 1 input
echo
if [[ "$input" == "y" ]] ; then 
    unbindDevice
else
    echo "User aborted."
    exit
fi

# 04:10.1 Ethernet controller: Intel Corporation 82599 Ethernet Controller Virtual Function (rev 01)
## 08:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
#DEVICE_ID="8086 1520"
#DEVICE_BDF="0000:09:10.1"
#echo "$DEVICE_ID" > /sys/bus/pci/drivers/pci-stub/new_id
#echo "$DEVICE_BDF" > /sys/bus/pci/drivers/igbvf/unbind
#echo "$DEVICE_BDF" > /sys/bus/pci/drivers/pci-stub/bind
#echo "$DEVICE_ID" > /sys/bus/pci/drivers/pci-stub/remove_id

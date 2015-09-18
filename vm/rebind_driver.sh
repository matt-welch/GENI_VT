#!/bin/bash

if [ -z $1 ] ; then 
    ORIG_DRIVER=ixgbe
    CURR_DRIVER=pci-stub
    DEVICE_BDF="04:00.0"
    DEVICE_VEND="8086"
    DEVICE_NUM="10fb"
else
    FNAME="${1}.unbound"
    INFO=$(cat $FNAME)
    DEVICE_VEND=$(echo $INFO | cut -d ' ' -f 1) 
    DEVICE_NUM=$(echo $INFO | cut -d ' ' -f 2) 
    ORIG_DRIVER=$(echo $INFO | cut -d ' ' -f 3)
    CURR_DRIVER=$(echo $INFO | cut -d ' ' -f 4)
    DEVICE_BDF="$(echo $INFO | cut -d ' ' -f 5)"
fi
DEVICE_ID="$DEVICE_VEND $DEVICE_NUM"
echo $DEVICE_ID
echo $ORIG_DRIVER
echo $CURR_DRIVER
echo $DEVICE_BDF

## example
#echo "8086 10fb" > /sys/bus/pci/drivers/ixgbe/new_id
#echo "0000:04:00.0" > /sys/bus/pci/drivers/pci-stub/unbind
#echo "0000:04:00.0" > /sys/bus/pci/drivers/ixgbe/bind
TARGET1="/sys/bus/pci/drivers/$ORIG_DRIVER/new_id"
TARGET2="/sys/bus/pci/drivers/$CURR_DRIVER/unbind"
TARGET3="/sys/bus/pci/drivers/$ORIG_DRIVER/bind"

echo "Driver: $DRIVER"
echo "BDF: $DEVICE_BDF"
echo "Dev ID: $DEVICE_ID"

echo "$DEVICE_ID" > $TARGET1
echo "0000:${DEVICE_BDF}" > $TARGET2
echo "0000:${DEVICE_BDF}" > $TARGET3


#!/bin/bash
DEVICE_ID="8086 1520"
DEVICE_BDF="0000:09:10.1"
modprobe pci-stub 
echo "$DEVICE_ID" > /sys/bus/pci/drivers/pci-stub/new_id
echo "$DEVICE_BDF" > /sys/bus/pci/drivers/igbvf/unbind
echo "$DEVICE_BDF" > /sys/bus/pci/drivers/pci-stub/bind
echo "$DEVICE_ID" > /sys/bus/pci/drivers/pci-stub/remove_id

#!/bin/bash

CPUTYPE="host,level=9"
NAME="node1_vm"
TELNET_PORT=4445


# start the bridge if it's not running
if [ "`/sbin/ifconfig | grep ^br0`" = "" ]; then
    /usr/bin/startbr.sh
fi

sudo taskset 0x2 qemu-system-x86_64 \
    -enable-kvm \
    -name $NAME \
    -cpu $CPUTYPE \
    -smp 4 \
    -m 4096 \
    -hda ubuntu.img \
    -no-hpet \
    -nographic \
    -vnc :1 \
    -monitor telnet::${TELNET_PORT},server,nowait \
    -serial stdio \
    -netdev tap,id=mattap0 \
    -device virtio-net-pci,netdev=mattap0 \
    -daemonize 


reset # terminal gets weird after qemu exits so reset it

#
#  I don't think these work - they may disable the vnc server
#    -chardev stdio,id=virtiocon0 \
#    -device virtio-serial \
#    -device virtconsole,chardev=virtiocon0 

# potential optimizations: 
# -no-reboot \
#    -net nic -net user \

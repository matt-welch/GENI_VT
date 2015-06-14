#!/bin/bash

CPUTYPE="host,level=9"
NAME="node1_vm"
TELNET_PORT=4445
DEBUG="debug"
#HUGE="default_hugepagesz=2M hugepagesz=2M hugepages=2048"
#KERNEL="/home/matt/images/vmlinuz-3.16.0-30-generic"
#KERN_OPTS="console=ttyS0 console=tty0 isolcpus=1-3 irqaffinity=0 rcu_nocbs=1-4 rcu_nocb_poll=1 clocksource=tsc tsc=perfect nohz_full=1-3 highres=off ${HUGE} selinux=0 enforcing=0 $DEBUG raid=noautodetect" 

# start the bridge if it's not running
if [ "`/sbin/ifconfig | grep ^br0`" = "" ]; then
    ./startbr.sh
fi

qemu-system-x86_64 \
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

# TODO: Add -mem-path /mnt/huge and -mem-prealloc

#reset # terminal gets weird after qemu exits so reset it

#
#  I don't think these work - they may disable the vnc server
#    -chardev stdio,id=virtiocon0 \
#    -device virtio-serial \
#    -device virtconsole,chardev=virtiocon0 

# potential optimizations: 
# -no-reboot \
#    -net nic -net user \

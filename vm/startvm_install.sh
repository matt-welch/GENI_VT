#!/bin/bash

CPUTYPE="host,level=9"
NAME="install_vm"

# This command should work if the bwloe command does not 
# qemu-system-x86_64 -cdrom ubuntu-14.04.3-server-amd64.iso -enable-kvm -name node1_vm -vnc :1 -smp 4 -m 4096 -hda ubuntu.img -net nic -net user

COMMAND="qemu-system-x86_64 \
    -boot once=d \
    -cdrom ubuntu-14.04.3-server-amd64.iso \
    -enable-kvm \
    -name $NAME \
    -cpu $CPUTYPE \
    -smp 4 \
    -m 4096 \
    -hda $GENI_HOME/vm/ubuntu.img \
    $QEMU_NET_USER \ 
    -vnc :1 \
    -daemonize "

echo $COMMAND


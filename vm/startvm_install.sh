#!/bin/bash
# file : startvm_install.sh
# desc : standard VM, installer for iso image into VM

source $GENI_HOME/vm/startvm_common_vars.sh

# variables specific to this particular VM configuration
CPUTYPE="host,level=9"
NAME="install_vm"
SYSIMG="-hda $GENI_HOME/vm/ubuntuLg.img -boot once=d -cdrom ubuntu-14.04.3-server-amd64.iso "

# This command should work if the below command does not 
# qemu-system-x86_64 -cdrom ubuntu-14.04.3-server-amd64.iso -enable-kvm -name node1_vm -vnc :1 -smp 4 -m 4096 -hda ubuntu.img -net nic -net user

COMMAND="qemu-system-x86_64 \
    -enable-kvm \
    -cpu $CPUTYPE \
    -smp 4 \
    -m 4096 \
    -no-hpet \
    -name $NAME \
    $SYSIMG \
    -no-reboot \
    -vnc :1 \
    -monitor telnet::${TELNET_PORT},server,nowait \
    $QEMU_NET_USER \
    $QEMU_NET_VF \
    -daemonize "

echo $COMMAND


#!/bin/bash
# file : startvm_standard.sh
# desc : standard VM, not performance tuned
# 

source $GENI_HOME/vm/startvm_common_vars.sh

# variables specific to this particular VM configuration
CPUTYPE="host,level=9"
NAME="node1_vm_std"

# start the bridge if it's not running
if [ "$(/sbin/ifconfig | grep ^br0)" = "" ]; then
    $GENI_HOME/vm/startbr.sh
fi

COMMAND="qemu-system-x86_64 \
    -enable-kvm \
    -name $NAME \
    -cpu $CPUTYPE \
    -smp 4 \
    -m 4096 \
    -hda $GENI_HOME/vm/ubuntu.img \
    -no-hpet \
    -no-reboot \
    -vnc :1 \
    -monitor telnet::${TELNET_PORT},server,nowait \
    $QEMU_NET_TAP \
    $QEMU_SSH_REDIR \
    -daemonize"
echo $COMMAND
eval "$COMMAND"

#reset # when using "-serial stdio", terminal gets weird after qemu exits so reset it

#
#  I don't think these work - they may disable the vnc server
#    -chardev stdio,id=virtiocon0 \
#    -device virtio-serial \
#    -device virtconsole,chardev=virtiocon0 

# potential optimizations: 
# -no-reboot \
#    -net nic -net user \i
#-net user[,vlan=n][,name=str][,net=addr[/mask]][,host=addr][,restrict=on|off]
#         [,hostname=host][,dhcpstart=addr][,dns=addr][,dnssearch=domain][,tftp=dir]
#         [,bootfile=f][,hostfwd=rule][,guestfwd=rule][,smb=dir[,smbserver=addr]]
#                connect the user mode network stack to VLAN 'n', configure its
#                DHCP server and enabled optional services
#
# -net user,id=myNet0,net=192.168.2.0/24,hostfwd=192.168.2.2:5555-192.168.2.4:23 \
#
#    -net user,net=192.168.2.22,hostfwd=tcp::10022-:22 \
#    -net nic 
#
#

# NOTE: to enable forwarding over SSH (VNC in particular): 
# ssh -L 5901:localhost:5901 -N -f -l mattwel pc4.instageni.illinois.edu
# then connect to localhost:5901 on the local host (VNC viewer)

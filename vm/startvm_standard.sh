#!/bin/bash
# file : startvm_standard.sh
# desc : standard VM, not performance tuned

source $GENI_HOME/vm/startvm_common_vars.sh

# variables specific to this particular VM configuration
CPUTYPE="host,level=9"
NAME="node1_vm_std"
SYSIMG="-hda $GENI_HOME/vm/ubuntuLg.img "

# one virtual function from eth1 for internet/control (enable_vfs)
CONTROL_DEVICE="09:10.1"
if [ -z "$(lspci | grep $CONTROL_DEVICE)" ] ; then 
    echo "$0: ERROR: Control network interface device <$CONTROL_DEVICE> not available."
    exit
fi
NET_CONTROL="-net none -device pci-assign,host=${CONTROL_DEVICE} " 

# one physical function from p258p1 for data (disable virtual functions)
P258P1_PF="04:00.0"
# one virtual function from p258p1 for VF-data (enable_vfs)
P258P1_VF="04:10.0"

DATA_DEVICE="$P258P1_PF"
if [ -z "$(lspci | grep $DATA_DEVICE)" ] ; then 
    echo "$0: ERROR: Data network interface device <$DATA_DEVICE> not available."
    exit
fi
NET_DATA="-device pci-assign,host=${DATA_DEVICE} "   

# bridged tap interface for alternate data traffic path
NET_DATA_TAP="-netdev tap,id=mattap0 -device virtio-net-pci,netdev=mattap0 "


# start the bridge if it's not running
if [ "$(/sbin/ifconfig | grep ^br0)" = "" ]; then
    $GENI_HOME/vm/networking/startbr.sh
else
    echo "Bridge br0 already up: "
    ifconfig br0
    route -vn | grep br0
fi

COMMAND="taskset 0x2 qemu-system-x86_64 \
    -enable-kvm \
    -cpu $CPUTYPE \
    -smp 4 \
    -m 4096 \
    -name $NAME \
    $SYSIMG \
    -vnc :1 \
    -monitor telnet::${TELNET_PORT},server,nowait \
    $NET_CONTROL \
    $NET_DATA \
    $NET_DATA_TAP \
    -daemonize"

echo $COMMAND
eval "$COMMAND"

ps -ef | grep qemu --color
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

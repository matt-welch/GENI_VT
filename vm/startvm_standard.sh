#!/bin/bash
# file : startvm_standard.sh
# desc : standard VM, not performance tuned

source $GENI_HOME/vm/startvm_common_vars.sh

### variables specific to this particular VM configuration
SYSIMG="-hda $GENI_HOME/vm/ubuntuLg.img "

### variables describing configuration state 
HOST_KERNEL=$(uname -r)
RTKERN=rt18
CPUTYPE="host,level=9"
# if (long_string.contains(small_string))
if [[ "$HOST_KERNEL" == *"$RTKERN"* ]] ; then 
    # we're running an RT-kernel, apply Rt-tuning to guest
    # check hugepages
    echo "Running under RT-Kernel $(uname -a)"
    CPU_PARAMS="-cpu $CPUTYPE -smp 4"
    source $GENI_HOME/util/memory_fcns.sh
    mount_hugetlbfs 
    MEM_PARAMS="-m 4096 -realtime mlock=on -mem-path /mnt/huge -mem-prealloc "
    QEMU_BINARY="taskset 0x2 qemu-system-x86_64"    
    NAME="node1_vm_${RTKERN}"
else
    # running standard kernel, no tuning
    CPU_PARAMS="-cpu $CPUTYPE -smp 4"
    MEM_PARAMS="-m 4096"
    QEMU_BINARY="qemu-system-x86_64"    
    NAME="node1_vm_std"
fi

##### GUEST NETWORKING OPTIONS #####
INTERFACE_LIST=" virtio_net ixgbe igbvf "  # ixgbevf 
NET_OPTS=""
if [[ $INTERFACE_LIST == *"igbvf"* ]] ; then 
    # one virtual function from eth1 for internet/control (enable_vfs)
    CONTROL_DEVICE="05:10.0"
    if [ -z "$(lspci | grep $CONTROL_DEVICE)" ] ; then 
        echo "$0: ERROR: Control network interface device <$CONTROL_DEVICE> not available."
        exit
    fi
    NET_CONTROL="-net none -device pci-assign,host=${CONTROL_DEVICE} " 
    NET_OPTS="$NET_OPTS $NET_CONTROL"
fi
if [[ $INTERFACE_LIST == *" ixgbe "* ]] ; then 
    # one physical function from ixgbe device for data (disable virtual functions)
    IXGBE_VF="03:00.1"
    DATA_DEVICE="$IXGBE_VF"
    if [ -z "$(lspci | grep $DATA_DEVICE)" ] ; then 
        echo "$0: ERROR: Data network interface device <$DATA_DEVICE> not available."
        exit
    fi
    NET_DATA="-device pci-assign,host=${DATA_DEVICE} "   
    NET_OPTS="$NET_OPTS $NET_DATA"
fi
if [[ $INTERFACE_LIST == *" ixgbevf "* ]] ; then 
    # one virtual function from p258p1 for VF-data (enable_vfs)
    P258P2_VF="05:10.1"
    NET_DATA_VF="-device pci-assign,host=${P258P2_VF} "   
    NET_OPTS="$NET_OPTS $NET_DATA_VF"
fi
if [[ $INTERFACE_LIST == *"virtio_net"* ]] ; then 
    # bridged tap interface for alternate data traffic path
    # start the bridge if it's not running
    # bridge is connected to p258p2 be default
    if [ "$(/sbin/ifconfig | grep ^br0)" = "" ]; then
        $GENI_HOME/vm/networking/startbr.sh
    else
        echo "Bridge br0 already up: "
        ifconfig br0
        route -vn | grep br0
    fi
    NET_DATA_TAP="-netdev tap,id=mattap0 -device virtio-net-pci,netdev=mattap0 "
    NET_OPTS="$NET_OPTS $NET_DATA_TAP"
fi

PIDFILE=qemu_gos.pid
COMMAND="$QEMU_BINARY \
    -enable-kvm \
    -name $NAME \
    -vnc :1 \
    -monitor telnet::${TELNET_PORT},server,nowait \
    -pidfile $PIDFILE \
    $CPU_PARAMS \
    $MEM_PARAMS \
    $SYSIMG \
    $NET_OPTS \
    -daemonize"

echo $COMMAND
eval "$COMMAND"

PID=$(cat $PIDFILE)
echo "Pidfile: $PID"

#if [[ "$HOST_KERNEL" == *"$RTKERN"* ]] ; then 
#    # pin vCPU threads if running in "RT" mode
#    ./pin_cpu_threads.sh $PID
#fi

ps -ef | grep $PID --color
#reset # when using "-serial stdio", terminal gets weird after qemu exits so reset it

# open a telnet connection to qemu to determine the vcpu TIDs
telnet localhost $TELNET_PORT 
# (qemu) info cpus ./pin_cpu_threads.sh

# PERFORMANCE TUNING TODO: control cpu pinning?  -numa
# node[,mem=size][,cpus=cpu[-cpu]][,nodeid=node]

#  I don't think these work - they may disable the vnc server -chardev
#  stdio,id=virtiocon0 \ -device virtio-serial \ -device
#  virtconsole,chardev=virtiocon0 

# potential optimizations: -no-reboot \ -net nic -net user \i
#-net user[,vlan=n][,name=str][,net=addr[/mask]][,host=addr][,restrict=on|off]
#         [,hostname=host][,dhcpstart=addr][,dns=addr][,dnssearch=domain][,tftp=dir]
#         [,bootfile=f][,hostfwd=rule][,guestfwd=rule][,smb=dir[,smbserver=addr]]
#         connect the user mode network stack to VLAN 'n', configure its DHCP
#         server and enabled optional services
#
# -net
# user,id=myNet0,net=192.168.2.0/24,hostfwd=192.168.2.2:5555-192.168.2.4:23 \
#
#    -net user,net=192.168.2.22,hostfwd=tcp::10022-:22 \ -net nic 
#
#

# NOTE: to enable forwarding over SSH (VNC in particular): ssh -L
# 5901:localhost:5901 -N -f -l mattwel pc4.instageni.illinois.edu then connect
# to localhost:5901 on the local host (VNC viewer)

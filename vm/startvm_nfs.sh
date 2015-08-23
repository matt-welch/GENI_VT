#!/bin/bash
# file : startvm_performance.sh
# desc : start a VM with NFS root 
#       TODO unify this with startvm_performance.sh using cmd line selection 
#

# below contains variables that should not change between VMs (Telnet port, etc)
source $GENI_HOME/vm/startvm_common_vars.sh

# variables specific to this particular VM configuration
CPUTYPE="host,level=9"
NAME="node1_vm_perf"
DEBUG="debug"
KERNEL_STD="$GENI_HOME/vm/vmlinuz-3.14.49"
KERNEL_RT="$GENI_HOME/vm/vmlinuz-3.14.49-rt50"
# NOTE: in append line, sda1 is boot partition, root partition is sda2
HUGE="" # remove hugepages from kernel params for debugging
ROOTDIR="root=/dev/nfs rw nfsroot=${NFS_IP}:${NFS_ROOTDIR} -rootfs $NET_CONFIG "
PARAMS="acpi=off console=ttyS0 console=tty0 isolcpus=1-3 irqaffinity=0 rcu_nocbs=1-4 rcu_nocb_poll=1 clocksource=tsc tsc=reliable nohz_full=1-3 $HUGE selinux=0 enforcing=0 $DEBUG raid=noautodetect"
KERNEL=$KERNEL_STD 
KERN_OPTS="${ROOTDIR} ${PARAMS}"
SYSIMG="-kernel $KERNEL -append \"$KERN_OPTS\" "

# start the bridge if it's not running
if [ "$(/sbin/ifconfig | grep ^br0)" = "" ]; then
    $GENI_HOME/vm/startbr.sh
fi

check_hugepages
EXITCODE="$?"
if [ "$EXITCODE" == 1 ] ; then 
    echo "Hugepage failure ... Aborting $0 "
    exit $EXITCODE
fi

echo "Kernel: $KERNEL"
echo "Parameters: \" $KERN_OPTS \"" 

COMMAND="qemu-system-x86_64 \
    -enable-kvm \
    -cpu $CPUTYPE \
    -smp 4 \
    -m 4096 -mem-path /mnt/huge -realtime mlock=on -mem-prealloc \
    -no-hpet \
    -name $NAME \
    $SYSIMG \
    -no-reboot \
    -vnc :1 \
    -monitor telnet::${TELNET_PORT},server,nowait \
    $QEMU_NET_TAP \
    $QEMU_NET_VF \
    -nographic -serial stdio"

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

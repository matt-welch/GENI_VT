#!/bin/bash
# file : startvm_performance.sh
# desc : VM with performance tuning incl. kernel tuning + NFS root
#        TODO: input arguments can select NFS or local HDD

# below contains variables that should not change between VMs (Telnet port, etc)
source $GENI_HOME/vm/startvm_common_vars.sh
KERNTYPE="$1" # kernel type can be [norm] or rt
TUNETYPE="$2" # tuning tupe can be full or [none]
ROOTTYPE="$3" # root type can be [local] (ubuntu.img) or nfs (nfsroot)

# variables specific to this particular VM configuration
CPUTYPE="host,level=9"
DEBUG="debug"
KERNEL_STD="$GENI_HOME/vm/vmlinuz-3.14.49"
KERNEL_RT="$GENI_HOME/vm/vmlinuz-3.14.49-rt50"
# NOTE: in append line, sda1 is boot partition, root partition is sda2
HUGE="" # remove hugepages from kernel params for debugging

# selection possibilities for system image and kernel 
LOCALROOT="root=/dev/sda2 "
LOCALHDD="-hda $GENI_HOME/vm/ubuntu.img "
NO_PARAMS="console=ttys0 console=tty0 raid=noautodetect $HUGE"

NFSROOT="root=/dev/nfs rw nfsroot=${NFS_IP}:${NFS_ROOTDIR} -rootfs $NET_CONFIG "
RT_PARAMS="acpi=off console=ttyS0 console=tty0 isolcpus=1-3 irqaffinity=0 rcu_nocbs=1-4 rcu_nocb_poll=1 clocksource=tsc tsc=reliable nohz_full=1-3 $HUGE selinux=0 enforcing=0 $DEBUG raid=noautodetect"

function usage (){
    echo "Usage: $0 [norm|rt] [none|full] [local|nfs]"
}

function showCmdLine(){
    echo "Run this VM configuration again with: \"$0 $KERNTYPE $TUNETYPE $ROOTTYPE \" "
}

if (( "$#" < 4 )) ; then 
    usage
fi

case "$KERNTYPE" in
norm)  echo "Using normal kernel ($KERNEL_STD)".
    KERNEL="$KERNEL_STD"
    ;;
rt)  echo  "Using preempt-rt kernel ($KERNEL_RT)."
    KERNEL="$KERNEL_RT"
    ;;
*) echo "\"$1\" is not a valid kernel, using normal kernel ($KERNEL_STD)"
    KERNTYPE=norm
    KERNEL="$KERNEL_STD"
    ;;
esac

case "$TUNETYPE" in
none)  echo "Using no kernel parameter tuning."
    PARAMS="$NO_PARAMS"
    MEM_CONFIG="$MEMSIZE"
    ;;
full)  echo  "Using maximal isolation tuning ($PARAMS)."
    PARAMS="$RT_PARAMS"
    MEM_CONFIG="$MEMSIZE $MEM_PERF"
    ;;
*) echo "\"$TUNETYPE\" is not a valid tuning option. Using no kernel parameter tuning."
    TUNETYPE=none
    PARAMS="$NO_PARAMS"
    MEM_CONFIG="$MEMSIZE"
    ;;
esac

case "$ROOTTYPE" in
local)  echo "Using local system image ($LOCALHDD)"
    SYSIMG="$LOCALHDD -kernel $KERNEL -append \"$LOCALROOT $PARAMS \""
    ;;
nfs)  echo  "Using NFS root system image ($NFSROOT)"
    SYSIMG="-kernel $KERNEL -append \" $NFSROOT $PARAMS \""
    ;;
*) echo "\"$1\" is not a valid system image, using local ($LOCALHDD)"
    ROOTTYPE=local
    SYSIMG="$LOCALHDD -kernel $KERNEL -append \"$LOCALROOT $PARAMS \""
   ;;
esac
showCmdLine

NAME="gos_${KERNTYPE}_${TUNETYPE}_${ROOTTYPE}"

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

COMMAND="qemu-system-x86_64 \
    -enable-kvm \
    -cpu $CPUTYPE \
    -smp 4 \
    $MEM_CONFIG \
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
exit
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

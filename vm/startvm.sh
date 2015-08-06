#!/bin/bash

source ../util/bash_colors.sh
CPUTYPE="host,level=9"
NAME="node1_vm"
TELNET_PORT=4445
DEBUG="debug"
HUGE="default_hugepagesz=2M hugepagesz=2M hugepages=2048"
#KERNEL="/home/matt/images/vmlinuz-3.16.0-30-generic"
KERNEL="/users/mattwel/images/vmlinuz-3.13.0-33-generic"
NET_CONFIG="ip=192.168.2.22::192.168.2.2:255.255.255.0::eth0::: "
KERN_OPTS="console=ttyS0 console=tty0 isolcpus=1-3 irqaffinity=0 rcu_nocbs=1-4 rcu_nocb_poll=1 clocksource=tsc tsc=perfect nohz_full=1-3 highres=off ${HUGE} selinux=0 enforcing=0 $DEBUG raid=noautodetect" 

# start the bridge if it's not running
if [ "$(/sbin/ifconfig | grep ^br0)" = "" ]; then
    ./startbr.sh
fi

# TODO check for hugepages, use them if available
NR_HUGE=$(cat /proc/sys/vm/nr_hugepages)
if [[ "$NR_HUGE" -eq "0" ]] ; then 
    fcn_print_red "No Hugepages available - aborting VM start."
    exit
fi

qemu-system-x86_64 \
    -enable-kvm \
    -name $NAME \
    -cpu $CPUTYPE \
    -smp 4 \
    -m 4096 \
    -hda ubuntu.img \
    -kernel $KERNEL \
    -append "root=/dev/sda1 $KERN_OPTS $NET_CONFIG " \
    -no-hpet \
    -nographic \
    -vnc :1 \
    -monitor telnet::${TELNET_PORT},server,nowait \
    -serial stdio \
    -netdev tap,id=mattap0 \
    -device virtio-net-pci,netdev=mattap0 \
    -redir tcp:10022::22

# TODO: Add -mem-path /mnt/huge and -mem-prealloc

#reset # terminal gets weird after qemu exits so reset it

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

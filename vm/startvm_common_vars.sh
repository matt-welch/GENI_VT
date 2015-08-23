#!/bin/bash
# file : startvm_common_vars.sh
# desc : 
# 

source $GENI_HOME/util/bash_colors.sh
source $GENI_HOME/util/ids.sh
source $GENI_HOME/util/memory_fcns.sh

TELNET_PORT=4445
HUGE="default_hugepagesz=2M hugepagesz=2M hugepages=2048"
# following are possible QEMU network configurations from simple to complex
QEMU_NET_USER="-net nic -net user "
QEMU_NET_TAP="-netdev tap,id=mattap0 -device virtio-net-pci,netdev=mattap0 "
QEMU_NET_PF="-device pci-assign,host=04:00.0 -device pci-assign,host=04:00.1 " 
QEMU_NET_VF="-device pci-assign,host=09:10.1" 
QEMU_SSH_REDIR="-redir tcp:10022::22 " 
QEMU_NET_BRIDGE="-netdev bridge,id=hostbr,br=br0,helper=/usr/lib/qemu-bridge-helper -net nic,model=virtio " 

# options for nfs root
NFS_IP="192.168.42.2"
NFS_ROOTDIR="/nfs/gos1"
GOS_IP="192.168.42.21"
NETMASK="255.255.255.0"
GOS_NAME="ubuntu-vm"
NET_CONFIG="ip=${GOS_IP}:${NFS_IP}:${GATEWAY}:${NETMASK}:${GOS_NAME}:eth0:off"

CPU="-enable-kvm -cpu $CPUTYPE -smp 4 "
MEM="-mem 4096 "
MEM_PERF="-realtime mlock=on -mem-path /path/to/mem -mem-prealloc "


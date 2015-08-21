#!/bin/bash
# file : startvm_common_vars.sh
# desc : 
# 

source $GENI_HOME/util/bash_colors.sh
source $GENI_HOME/util/ids.sh

TELNET_PORT=4445
HUGE="default_hugepagesz=2M hugepagesz=2M hugepages=2048"
NET_CONFIG="ip=192.168.2.21::192.168.2.2:255.255.255.0::eth0::: "
# following are possible QEMU network configurations from simple to complex
QEMU_NET_USER="-net nic -net user "
QEMU_NET_TAP="-netdev tap,id=mattap0 \
    -device virtio-net-pci,netdev=mattap0 "
QEMU_NET_PF="-device pci-assign,host=04:00.0 \ 
    -device pci-assign,host=04:00.1 " 
QEMU_NET_VF="-device pci-assign,host=09:10.1" 
QEMU_SSH_REDIR="-redir tcp:10022::22 " 
QEMU_NET_BRIDGE="-netdev bridge,id=hostbr,br=br0,helper=/usr/lib/qemu-bridge-helper -net nic,model=virtio " 


function check_hugepage_status () {
    # check for hugepages, abort ifthey're not available
    NR_HUGE=$(cat /proc/sys/vm/nr_hugepages)
    if [[ "$NR_HUGE" -eq "0" ]] ; then 
        fcn_print_red "No Hugepages available - aborting VM start."
        exit 1 
    fi
}

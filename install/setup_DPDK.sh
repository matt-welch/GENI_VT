#!/bin/bash

if [ -z "$GENI_HOME" ] ; then 
    echo "The GENI_HOME variable has not been defined."
fi

source $GENI_HOME/util/ids.sh
source $GENI_HOME/util/bash_colors.sh
source $GENI_HOME/util/sys_vars.sh
PKTGEN="$HOMEDIR/dpdk/pktgen-2.9.1/app/app/x86_64-native-linuxapp-gcc/pktgen"

function mount_hugetlbfs () {
    MOUNTPOINT="/mnt/huge"
    sudo mkdir -p $MOUNTPOINT
    ISMOUNTED=$(mount | grep hugetlbfs)

    if [[ -z "$ISMOUNTED" ]] ; then 
        fcn_print_red "Mounting hugetlbfs ... "
        sudo mount -t hugetlbfs none $MOUNTPOINT
    fi
    fcn_print_red "HugeTLB FS mount: "
    mount | grep hugetlbfs
}

function setup_dpdk() {
    echo
    fcn_print_red "Setting up DPDK ..."
    cd $HOMEDIR/dpdk
    source RTE_vars.sh

    # assumes DPDK 2.0.0 is already installed & built 
    cd $RTE_SDK/$RTE_TARGET

    fcn_print_red "Setting up drivers..."
    # insert drivers
    sudo modprobe uio

    if [ -n "$(lsmod | grep igb_uio)" ] ; then 
        sudo rmmod igb_uio
    fi
    sudo insmod kmod/igb_uio.ko
    lsmod | grep -e uio -e igb

    mount_hugetlbfs 

    fcn_print_red "Binding $IF1_NAME ($IF1_PCI) & $IF2_NAME ($IF2_PCI) to igb_uio driver..."
    if [ -n "$(ifconfig -a | grep $IF1_NAME)" ] ; then 
        sudo ifconfig $IF1_NAME down
    fi
    if [ -n "$(ifconfig -a | grep $IF2_NAME)" ] ; then 
        sudo ifconfig $IF2_NAME down
    fi
    cd $RTE_SDK/tools/
    echo -e "\nInterface status $(fcn_print_red BEFORE) binding"
    sudo ./dpdk_nic_bind.py --status

    # after checking the status, bind the igb_uio driver to the data (not eth0) interfaces
    sudo ./dpdk_nic_bind.py -b igb_uio $IF1_PCI $IF2_PCI 
    echo -e "\nInterface status $(fcn_print_red AFTER) binding"
    sudo ./dpdk_nic_bind.py --status
    fcn_print_red "DPDK setup complete."
}

function teardown_dpdk () {
    echo 
    fcn_print_red "Unbinding interfaces from DPDK drivers and rebinding to ixgbe... "
    cd $HOMEDIR/dpdk
    source RTE_vars.sh 
    cd $RTE_SDK/tools

    ./dpdk_nic_bind.py -u $IF1_PCI $IF2_PCI
    ./dpdk_nic_bind.py -b ixgbe $IF1_PCI $IF2_PCI
    ./dpdk_nic_bind.py --status 

}



function setup_pktgen () {
    setup_dpdk
    echo
    fcn_print_red "Setting up pktgen"

    cd $PKTGEN_HOME

#    BOUND=$($RTE_SDK/tools/dpdk_nic_bind.py --status | grep drv=igb_uio )
#
#    if [[ -z "$BOUND" ]] ; then 
#        echo "ERROR: No interfaces bound to igb_uio"
#        echo "  use $RTE_SDK/tools/dpdk_nic_bind.py -b igb_uio bb:dd.f "
#    fi
    $GENI_HOME/benchmarks/run_pktgen.sh
}


#!/bin/bash

if [ -z "$GENI_HOME" ] ; then 
    echo "The GENI_HOME variable has not been defined."
fi

source ${GENI_HOME}/util/ids.sh
source ${GENI_HOME}/util/bash_colors.sh
source ${GENI_HOME}/util/sys_vars.sh
PKTGEN="${HOMEDIR}/dpdk/pktgen-2.9.1/app/app/x86_64-native-linuxapp-gcc/pktgen"

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
    fcn_print_red "Setting up DPDK ..."
    cd ${HOMEDIR}/dpdk
    source RTE_vars.sh

    # assumes DPDK 2.0.0 is already installed & built 
    cd ${RTE_SDK}/${RTE_TARGET}

    fcn_print_red "Setting up drivers..."
    # insert drivers
    sudo modprobe uio

    if [ -n "$(lsmod | grep igb_uio)" ] ; then 
        sudo rmmod igb_uio
    fi
    sudo insmod kmod/igb_uio.ko
    lsmod | grep -e uio -e igb

    mount_hugetlbfs 

    fcn_print_red "Binding $IF1 & $IF2 to igb_uio driver..."
    sudo ifconfig $IF1 down
    sudo ifconfig $IF2 down
    cd ${RTE_SDK}/tools/
    ./dpdk_nic_bind.py --status

    # after checking the status, bind the igb_uio driver to the data (not eth0) interfaces
    ./dpdk_nic_bind.py -b igb_uio $IF1_PCI $IF2_PCI 
    ./dpdk_nic_bind.py --status
    fcn_print_red "DPDK setup complete."
}


function setup_pktgen () {
    setup_dpdk
    cd ~/dpdk
    source RTE_vars.sh

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


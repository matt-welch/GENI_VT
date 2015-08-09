#!/bin/bash

PKTGEN="/users/mattwel/dpdk/pktgen-2.9.1/app/app/x86_64-native-linuxapp-gcc/pktgen"

function mount_hugetlbfs () {
    MOUNTPOINT="/mnt/huge"
    sudo mkdir -p $MOUNTPOINT
    ISMOUNTED=$(mount | grep hugetlbfs)

    if [[ -z "$ISMOUNTED" ]] ; then 
        sudo mount -t hugetlbfs none $MOUNTPOINT
    fi
    mount | grep hugetlbfs
}

function setup_dpdk() {
    cd ~/dpdk
    source RTE_vars.sh

    # assumes DPDK 2.0.0 is already isntalled
    cd dpdk-2.0.0/${RTE_TARGET}

    # insert drivers
    sudo modprobe uio
    sudo insmod kmod/igb_uio.ko

    mount_hugetlbfs 
    # these interfaces will likely not be correct
    ifconfig eth1 down
    ifconfig eth3 down
    cd tools/
    ./dpdk_nic_bind.py --status

    # after checking the status, bind the igb_uio driver to the data (not eth0) interfaces
}


function setup_pktgen () {
    cd ~/dpdk
    source RTE_vars.sh

    cd pktgen-2.9.1/
    mount_hugetlbfs


}

function run_pktgen () {
    ARGS=' -c 0x1e -n 4 -- -p 0x3 -m "2.0,3.1" '
    COMMAND="$PKTGEN $ARGS"
    echo $COMMAND

}


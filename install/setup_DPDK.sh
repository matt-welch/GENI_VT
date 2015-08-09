#!/bin/bash

function setup_dpdk() {
    cd ~/dpdk
    source RTE_vars.sh

    # assumes DPDK 2.0.0 is already isntalled
    cd dpdk-2.0.0/${RTE_TARGET}

    # insert drivers
    sudo modprobe uio
    sudo insmod kmod/igb_uio.ko


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


}

#!/bin/bash

function setup_dpdk() {
    # assumes DPDK 2.0.0 is already isntalled
    cd /users/mattwel/dpdk-2.0.0/
    # these interfaces will likely not be correct
    ifconfig eth1 down
    ifconfig eth3 down
    cd tools/
    ./dpdk_nic_bind.py --status

    # after checking the status, bind the igb_uio driver to the data (not eth0) interfaces
}

function setup_pktgen () {

}

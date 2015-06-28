#!/bin/bash

function install_iperf {
    git clone https://github.com/esnet/iperf.git
    cd iperf
    ./configure 
    ./make
    make
    sudo make install
}

BENCH_LIST="iperf cpumem bw_mem"

for i in ${BENCH_LIST[@]}; do
    echo "Installing $i ..."
    install_${i}
done

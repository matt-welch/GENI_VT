#!/bin/bash

KERNELGIT=git://git.kernel.org/pub/scm/linux/kernel/git
BENCH_LIST="iperf cyclictest "
BENCH_DIR="~/benchmarks"
mkdir -p $BENCH_DIR
cd $BENCH_DIR

function install_iperf() {
    git clone https://github.com/esnet/iperf.git
    cd iperf
    ./configure 
    make -j $(nproc)
    sudo make install
}

function install_cyclictest() {
    sudo apt-get install -y build-essential libnuma-dev 
    git clone $KERNELGIT/clrkwllms/rt-tests.git
    cd rt-tests
    make -j $(nproc)
}

for BENCHMARK in ${BENCH_LIST[@]}; do
    cd $BENCH_DIR
    echo "Installing $BENCHMARK ..."
    install_${BENCHMARK}
done

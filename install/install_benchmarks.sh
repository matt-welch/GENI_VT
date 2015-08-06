#!/bin/bash

KERNELGIT=git://git.kernel.org/pub/scm/linux/kernel/git
BENCH_LIST="iperf cyclictest "
BENCH_DIR="/users/mattwel/GENI_VT/benchmarks"
mkdir -p $BENCH_DIR
cd $BENCH_DIR

function install_iperf() {
    THIS_DIR=iperf
    if [[ -d $THIS_DIR ]] ; then
        cd iperf
        if [[ -f install_complete ]] ; then
            echo "$THIS_DIR is already installed"
        else
            echo "An error has occurred - $THIS_DIR installation has failed"
        fi
    else
        git clone https://github.com/esnet/iperf.git
        cd iperf
        ./configure
        make -j $(nproc)
        sudo make install
        ln -s /users/mattwel/GENI_VT/benchmarks/iperf/src/iperf3 $BENCH_DIR/iperf3
        date > install_complete
    fi
}

function install_cyclictest() {
    exit
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


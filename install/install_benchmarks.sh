#!/bin/bash

KERNELGIT=git://git.kernel.org/pub/scm/linux/kernel/git
BENCH_LIST="iperf cyclictest "
BENCH_DIR="/users/mattwel/GENI_VT/benchmarks"
mkdir -p $BENCH_DIR
cd $BENCH_DIR

function install_iperf() {
    THIS_DIR=iperf
    if [[ -d $THIS_DIR ]] ; then
        cd $THIS_DIR
        if [[ -f install_complete ]] ; then
            echo "$THIS_DIR is already installed"
        else
            echo "An error has occurred - $THIS_DIR installation has failed"
        fi
    else
        git clone https://github.com/esnet/iperf.git
        cd $THIS_DIR
        ./configure
        make -j $(nproc)
        ln -s /users/mattwel/GENI_VT/benchmarks/iperf/src/iperf3 $BENCH_DIR/iperf3
        date > install_complete
    fi
}

function install_cyclictest() {
    THIS_DIR=rt-tests
    if [[ -d $THIS_DIR ]] ; then
        cd $THIS_DIR
        if [[ -f install_complete ]] ; then
            echo "$THIS_DIR is already installed"
        else
            echo "An error has occurred - $THIS_DIR installation has failed"
        fi
    else
        sudo apt-get install -y build-essential libnuma-dev
        git clone $KERNELGIT/clrkwllms/rt-tests.git
        cd rt-tests
        make -j $(nproc)
        ln -s /users/mattwel/GENI_VT/benchmarks/$THIS_DIR/cyclictest $BENCH_DIR/cyclictest
        date > install_complete
    fi
}

for BENCHMARK in ${BENCH_LIST[@]}; do
    cd $BENCH_DIR
    echo "Installing $BENCHMARK ..."
    install_${BENCHMARK}
done


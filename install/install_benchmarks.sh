#!/bin/bash

cd $GENI_HOME
source $GENI_HOME/util/ids.sh # contains USER, HOMEDIR, KEY
source $GENI_HOME/util/bash_colors.sh
KERNELGIT=git://git.kernel.org/pub/scm/linux/kernel/git
BENCH_LIST="iperf cyclictest netperf"
ALL_BENCHMARKS=$(sed -n -e 's/THIS_BENCH=\([a-z\-]*\)/\1/p' \
    ${GENI_HOME}/install/install_benchmarks.sh)

BENCH_DIR="${HOMEDIR}/GENI_VT/benchmarks"
if [ -z "$HOMEDIR" ] ; then 
    echo this is weird
fi

function install_iperf() {
    THIS_BENCH=iperf
    if [[ -d $THIS_BENCH ]] ; then
        cd $THIS_BENCH
        if [[ -f install_complete ]] ; then
            echo "$THIS_BENCH is already installed"
        else
            echo "An error has occurred - $THIS_BENCH installation has failed"
        fi
    else
        git clone https://github.com/esnet/iperf.git
        cd $THIS_BENCH
        ./configure
        make -j $(nproc)
        ln -s ${HOMEDIR}/GENI_VT/benchmarks/iperf/src/iperf3 $BENCH_DIR/iperf3
        date > install_complete
    fi
}

function install_dependencies_cyclictest() {
    if [[ -z $(which apt-get) ]] ; then 
        sudo yum install -y numactl-devel.x86_64
    else
        sudo apt-get install -y build-essential libnuma-dev
    fi
}
function install_cyclictest() {
    THIS_BENCH=rt-tests
    if [[ -d $THIS_BENCH ]] ; then
        cd $THIS_BENCH
        if [[ -f install_complete ]] ; then
            echo "$THIS_BENCH is already installed"
        else
            echo "An error has occurred - $THIS_BENCH installation has failed"
        fi
    else
        install_dependencies_cyclictest
        git clone https://git.kernel.org/pub/scm/linux/kernel/git/clrkwllms/rt-tests.git
        cd rt-tests
        make -j $(nproc)
        ln -s ${HOMEDIR}/GENI_VT/benchmarks/$THIS_BENCH/cyclictest $BENCH_DIR/cyclictest
        date > install_complete
    fi
}

function install_netperf() {
    THIS_BENCH=netperf
    if [[ -d $THIS_BENCH ]] ; then
        cd $THIS_BENCH
        if [[ -f install_complete ]] ; then
            echo "$THIS_BENCH is already installed"
        else
            echo "An error has occurred - $THIS_BENCH installation has failed"
        fi
    else
        #mkdir -p $THIS_BENCH
        #cd $THIS_BENCH
        URL="ftp://ftp.netperf.org/netperf/netperf-2.7.0.tar.bz2"
        FILE=$(basename $URL)
        fcn_print_red "Downloading $FILE ..."
        curl -# $URL -o $FILE
        fcn_print_red "Extracting $FILE ..."
        tar xvf $FILE 
        DIR=${FILE%.tar.bz2}
        cd $DIR
        NETPERFDIR=$(pwd)
        fcn_print_red "Configuring $THIS_BENCH ..."
        ./configure && fcn_print_red "Building $THIS_BENCH ..." && make 
        fcn_print_red "Linking $THIS_BENCH ..."
        ln -s ${NETPERFDIR}/src/netperf $BENCH_DIR/
        ln -s ${NETPERFDIR}/src/netserver $BENCH_DIR/
        date > install_complete
    fi
}

mkdir -p $BENCH_DIR
cd $BENCH_DIR
for BENCHMARK in ${BENCH_LIST[@]}; do
    cd $BENCH_DIR
    fcn_print_red "Installing $BENCHMARK ..."
    install_${BENCHMARK}
done


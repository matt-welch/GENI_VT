#!/bin/bash

source ../util/ids.sh

function printHeader {
    echo 
    echo -n ">>>>GENI_VT:: $0 :: "
}

function installPackages {
    printHeader  
    echo " Installing necessary packages and tools..."
    ### install useful tools
    sudo apt-get update 
    # install utilities
    sudo apt-get install -y vim ethtool screen qemu-kvm exuberant-ctags apparmor bridge-utils 
    # NOTE: apparmor is to enable docker; 
    # http://stackoverflow.com/questions/29294286/fata0000-get-http-var-run-docker-sock-v1-17-version-dial-unix-var-run-doc
}

function installKernel {
    WD=$(pwd)
    # install kernel build tools
    sudo apt-get install -y build-dep linux-source linux-image-`uname -r` libncurses5 libncurses5-dev gcc 
    # these might also be needed: 
    # lib64c-dev:i386 lib64ncurses5 lib64ncurses5-dev
    # NOTE: I think it would be easier to just compile a clean kernel from kernel.org: 
    sudo cd /usr/src/
    VERSION="3.14.48"
    FILE="linux-${VERSION}.tar.xz"
    
    sudo wget https://www.kernel.org/pub/linux/kernel/v3.x/${FILE}
    #tar xvf ${FILE}
    sudo cd $WD
}

function installExptTools {
    ### Install experiment software
    # TODO make it an option to install docker
    ### make links to start scripts & qemu-ifup
    printHeader  
    echo "Preparing vm files..."
    sudo ln -s ~/GENI_VT/startvm.sh ~/images/startvm.sh
    sudo mv /etc/qemu-ifup ./qemu-ifup.orig
    sudo ln -s ~/GENI_VT/qemu-ifup /etc/qemu-ifup
}
    
function installDocker {
    ### install Docker
    printHeader  
    echo " Installing Docker..."
    DOCKER=$(which docker)
    
    if [[ -z $DOCKER ]];
    then
        wget -qO- https://get.docker.com/ | sh
        sudo usermod -aG docker mattwel
        sudo service docker start
    fi
    sudo docker run hello-world
}

function installDPDK {
    ### Download, build dpdk
    # git clone git://dpdk.org/apps/pktgen-dpdk
    printHeader  
    echo "Downloading and installing dpdk..."
    cd ~/
    mkdir dpdk
    cd dpdk
    wget http://dpdk.org/browse/dpdk/snapshot/dpdk-2.0.0.tar.gz
    tar xvf dpdk-2.0.0.tar.gz
    cd dpdk-2.0.0/

cat << EOF > ../RTE_vars.sh
export RTE_SDK=$(pwd)
export RTE_TARGET="x86_64-native-linuxapp-gcc"
EOF

    . ../RTE_vars.sh

    printHeader  
    
    echo "Building DPDK..."
    make config O=${RTE_TARGET} T=${RTE_TARGET}
    cd ${RTE_TARGET} 
    make -j $(nproc)
}

function install_pktgen() {
    source /users/mattwel/GENI_VT/util/ids.sh
    PACKAGE="pktgen"
    VERSION="2.9.1"
    FORMAT="tar.gz"
    DIRECTORY="${PACKAGE}-${VERSION}"
    FILENAME="${PACKAGE}-${VERSION}.${FORMAT}"
    SOURCEURL="http://dpdk.org/browse/apps/pktgen-dpdk/snapshot/${FILENAME}"
    cd /users/${USER}/dpdk
    if [[ -f "RTE_vars.sh" ]] ; then 
        . ./RTE_vars.sh
    else
        echo "DPDK is not installed yet.  Exiting..."
        exit
    fi

    wget $SOURCEURL
    tar xvf $($FILENAME)
    cd ${DIRECTORY}
    make 
}

function collectSysInfo {
    printHeader  
    echo " Collecting system info..."
    cd ~/GENI_VT/
    sudo ./collect_sys_info.sh
}

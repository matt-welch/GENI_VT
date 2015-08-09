#!/bin/bash

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
    wget http://dpdk.org/browse/dpdk/snapshot/dpdk-2.0.0.tar.gz
    tar xvf dpdk-2.0.0.tar.gz
    cd dpdk-2.0.0/
    printHeader  
    echo "Building DPDK..."
    make -j $(nproc) config T=x86_64-native-linuxapp-gcc && make -j $(nproc)
}

function collectSysInfo {
    printHeader  
    echo " Collecting system info..."
    cd ~/GENI_VT/
    sudo ./collect_sys_info.sh
}

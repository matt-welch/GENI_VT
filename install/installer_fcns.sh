#!/bin/bash

source $GENI_HOME/util/ids.sh
source $GENI_HOME/util/bash_colors.sh

function printHeader() {
    echo 
    echo -n ">>>>GENI_VT:: $0 :: "
}

function installPackages() {
    printHeader  
    echo " Installing necessary packages and tools..."
    ### install useful tools
    sudo apt-get update 
    # install utilities
    sudo apt-get install -y vim ethtool screen qemu-kvm exuberant-ctags apparmor bridge-utils libpcap-dev nfs-kernel-server
    # NOTE: apparmor is to enable docker; 
    # http://stackoverflow.com/questions/29294286/fata0000-get-http-var-run-docker-sock-v1-17-version-dial-unix-var-run-doc
}

function installKernel() {
    WD=$(pwd)
    # install kernel build tools
    sudo apt-get install -y linux-source linux-image-`uname -r` libncurses5 libncurses5-dev gcc 
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

function installExptTools() {
    ### Install experiment software
    # TODO make it an option to install docker
    ### make links to start scripts & qemu-ifup
    printHeader  
    echo "Preparing vm files..."
    sudo ln -s $GENI_HOME/GENI_VT/vm/startvm.sh ~/images/vm/startvm.sh
    sudo mv /etc/qemu-ifup ./qemu-ifup.orig
    sudo ln -s $GENI_HOME/GENI_VT/vm/qemu-ifup /etc/qemu-ifup
}
    
function installDocker() {
    ### install Docker
    printHeader  
    echo " Installing Docker..."
    DOCKER=$(which docker)
    
    if [[ -z $DOCKER ]];
    then
        wget -qO- https://get.docker.com/ | sh
        sudo usermod -aG docker $USER
        sudo service docker start
    fi
    sudo docker run hello-world
}

function installDPDK() {
    CWD=$(pwd)
    PACKAGE="dpdk"
    VERSION="2.0.0"
    FORMAT="tar.gz"
    DIRECTORY="${PACKAGE}-${VERSION}"
    FILENAME="${DIRECTORY}.${FORMAT}"
    SOURCEURL=
    ### Download, build dpdk
    printHeader  
    echo "Downloading and installing dpdk..."
    cd $HOMEDIR
    mkdir dpdk
    cd dpdk
    wget $SOURCEURL
    tar xvf $FILENAME
    cd $DIRECTORY/

cat << EOF > ../RTE_vars.sh
export RTE_SDK=$(pwd)
export RTE_TARGET="x86_64-native-linuxapp-gcc"
export DPDK_VER="${VERSION}"
EOF

    . ../RTE_vars.sh

    printHeader  
    
    echo "Building DPDK..."
    make config O=${RTE_TARGET} T=${RTE_TARGET}
    cd ${RTE_TARGET} 
    make -j $(nproc)
    cd $CWD
}

function install_pktgen() {
    CWD=$(pwd)
    PACKAGE="pktgen"
    VERSION="2.9.1"
    FORMAT="tar.gz"
    DIRECTORY="${PACKAGE}-${VERSION}"
    FILENAME="${DIRECTORY}.${FORMAT}"
    SOURCEURL="http://dpdk.org/browse/apps/pktgen-dpdk/snapshot/${FILENAME}"
    cd ${HOMEDIR}/dpdk
    if [[ -f "RTE_vars.sh" ]] ; then 
        . ./RTE_vars.sh
    else
        echo "DPDK is not installed yet.  Exiting..."
        exit
    fi
    SHA256SUM="19fd30f6cc8768045e566b5c0bec9d0b744284728d55eeee1ba70d322d206486  pktgen-2.9.1.tar.gz"
    DL_FILE=1
    if [ -f "$FILENAME" ] ; then 
        echo "File <${FILENAME}> found, checking sha256sum..."
        if [[ "$(sha256sum $FILENAME)" != "$SHA256SUM" ]] ; then 
            echo "$(fcn_print_red "$FILENAME does not match sha256sum.")  Downloading..."
            DL_FILE=1
        else
            fcn_print_red "$FILENAME matches sha256sum. Skipping download."
        fi
    fi
    if [[ "DL_FILE" == 1 ]] ; then 
        echo "Downloading $PACKAGE v$VERSION from $SOURCEURL ... "
        wget $SOURCEURL
    fi
    echo "Extracting $FILENAME"
    tar xvf $FILENAME
    cd ${DIRECTORY}
    echo "Building $PACKAGE at $(date) ..."
    make && echo "Build of $PACKAGE v$VERSION is complete."

    cd $CWD
}

function collectSysInfo() {
    printHeader  
    echo " Collecting system info..."
    cd ~/GENI_VT/
    sudo ./collect_sys_info.sh
}


if [ "$0" == "/bin/bash" ] ; then 
    echo "Running function from bash..."
    exit
fi

FUNCLIST=$(grep function $0 | grep -v FUNC | sed -n -e 's/function \([a-zA-Z_]*\).*{/\1/p')
if [ -n "$FUNCLIST" ] ; then 
    echo $FUNCLIST
    PS3="Select an installer fcn to run: "
    select RUNFUNC in $FUNCLIST; 
    do 
        echo "Running ${RUNFUNC}()... " && break
        echo "Invalid selection, aborting."
    done
    echo
    
    $RUNFUNC
fi
# probably running in bash after sourcing.  DO nothing


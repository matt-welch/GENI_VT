#!/bin/bash
# local variable definitions
# Usual directory for downloading software in ProtoGENI hosts is `/local`
INSTALLDIR="/local"
HOMEDIR="/users/mattwel"
LOGDIR=$HOMEDIR/results/logs/


# local function definitions
function printHeader {
    echo 
    echo -n ">>>>GENI_VT:: $0 :: "
}

function logPrint {
    # logs info to logdir (1st arg is message, 2nd is filename
    sudo echo "$(date): $1" | tee -a  "$LOGDIR/$2"
}

function installPackages {
    printHeader  
    logPrint " Installing necessary packages and tools..." install.log
    ### install useful tools
    sudo apt-get update & EPID=$!
    wait $EPID
    # install utilities
    sudo apt-get install -y vim ethtool screen qemu-kvm exuberant-ctags apparmor bridge-utils & EPID=$!
    wait $EPID
    # NOTE: apparmor is to enable docker; 
    # http://stackoverflow.com/questions/29294286/fata0000-get-http-var-run-docker-sock-v1-17-version-dial-unix-var-run-doc
}

function installDPDK {
    ### Download, build dpdk
    # git clone git://dpdk.org/apps/pktgen-dpdk
    printHeader  
    logPrint "Downloading and installing dpdk..." dpdk.log
    cd $INSTALLDIR
    wget http://dpdk.org/browse/dpdk/snapshot/dpdk-2.0.0.tar.gz
    tar xvf dpdk-2.0.0.tar.gz -C $HOMEDIR
    cd $HOMEDIR/dpdk-2.0.0/
    printHeader  
    logPrint "Building DPDK..." dpdk.log
    make -j $(nproc) config T=x86_64-native-linuxapp-gcc && make -j $(nproc) & EPID=$!
    wait $EPID
}

function installDocker {
    ### install Docker
    printHeader  
    logPrint " Installing Docker..." docker.log
    DOCKER=$(which docker)
    
    if [[ -z $DOCKER ]];
    then
        wget -qO- https://get.docker.com/ | sh
        sudo usermod -aG docker mattwel
        sudo service docker start
    fi
    sudo docker run hello-world
}

# Begin control/bootstrapNode.sh
cd $INSTALLDIR
##### Check if file is there #####
if [ ! -f "./installed.txt" ]
then
    #### Create the file ####
    sudo date > "$INSTALLDIR/installed.txt"

    #### Run  one-time commands ####
    echo "Making results directory..."
    mkdir -p $LOGDIR

    #Install necessary packages
    installPackages
    installDPDK
    installDocker

    # extract VM image tarball
    cd $INSTALLDIR
    tar xvf ubuntu.tar.bz2 -C $HOMEDIR

    # Install custom software

    # For my experiment I need to <configure something custom>

    # echo cpmpletion time
    sudo date >> "$INSTALLDIR/installed.txt"
    ## Reboot the OS to ....
    #sudo reboot
fi
##### Run Boot-time commands
printHeader
logPrint "$(hostname) booting and running bootstrapNode.sh at $(date)"

# end of bootstrapNode.sh


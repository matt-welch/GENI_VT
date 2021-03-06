# local variable definitions
# Usual directory for downloading software in ProtoGENI hosts is `/local`
INSTALLDIR="/local"
source util/ids.sh # contains USER, HOMEDIR, KEY
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
    sudo apt-get install -y vim ethtool screen qemu-kvm exuberant-ctags apparmor bridge-utils libncurses5 libncurses5-dev gcc build-essential libnuma-dev & EPID=$!
    wait $EPID
    # NOTE: apparmor is to enable docker; 
    # http://stackoverflow.com/questions/29294286/fata0000-get-http-var-run-docker-sock-v1-17-version-dial-unix-var-run-doc
    logPrint "Package installation is complete." install.log
}

function installDPDK {
    ### Download, build dpdk
    # git clone git://dpdk.org/apps/pktgen-dpdk
    printHeader  
    logPrint "Downloading and installing dpdk..." dpdk.log
    cd $HOMEDIR
    wget http://dpdk.org/browse/dpdk/snapshot/dpdk-2.0.0.tar.gz
    tar xvf dpdk-2.0.0.tar.gz -C $HOMEDIR
    cd $HOMEDIR/dpdk-2.0.0/
    printHeader  
    logPrint "Building DPDK..." dpdk.log
    make -j $(nproc) config T=x86_64-native-linuxapp-gcc && make -j $(nproc) & EPID=$!
    wait $EPID
}
function installBuildTools {
    logPrint " Installing necessary kernel build packages and tools..." install.log
    WD=$(pwd)
    # install kernel build tools
    sudo apt-get install -y  libncurses5 libncurses5-dev gcc
    # these might also be needed:
    # lib64c-dev:i386 lib64ncurses5 lib64ncurses5-dev
    # NOTE: I think it would be easier to just compile a clean kernel from kernel.org:
#    sudo cd /usr/src/
#    VERSION="3.14.48"
#    FILE="linux-${VERSION}.tar.xz"
#
#    sudo wget https://www.kernel.org/pub/linux/kernel/v3.x/${FILE}
#    #tar xvf ${FILE}
#    sudo cd $WD
}

function installDocker {
    ### install Docker
    printHeader  
    logPrint " Installing Docker..." docker.log
    DOCKER=$(which docker)
    
    if [[ -z $DOCKER ]];
    then
        wget -qO- https://get.docker.com/ | sh
        sudo usermod -aG docker $USER
        sudo service docker start
    fi
    sudo docker run hello-world
}
mkdir -p $HOMEDIR/results/logs


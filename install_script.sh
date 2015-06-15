#!/bin/bash

### install useful tools
sudo apt-get update 
sudo apt-get install -y vim ethtool screen qemu-kvm exuberant-ctags apparmor bridge-utils 
# NOTE: apparmor is to enable docker; 
# http://stackoverflow.com/questions/29294286/fata0000-get-http-var-run-docker-sock-v1-17-version-dial-unix-var-run-doc

### Install experiment software
# TODO make it an option to install docker


### make links to start scripts & qemu-ifup
echo "Preparing vm files..."
ln -s ~/GENI_VT/startvm.sh ~/images/startvm.sh
sudo mv /etc/qemu-ifup ./qemu-ifup.orig
sudo ln -s $(pwd)/qemu-ifup /etc/qemu-ifup

### install Docker
DOCKER=$(which docker)

if [[ -z $DOCKER ]];
then
    wget -qO- https://get.docker.com/ | sh
    sudo usermod -aG docker mattwel
    sudo service docker start
fi
sudo docker run hello-world

### Download, build dpdk
# git clone git://dpdk.org/apps/pktgen-dpdk
echo "Downloading and installing dpdk..."
cd ~/
wget http://dpdk.org/browse/dpdk/snapshot/dpdk-2.0.0.tar.gz
tar xvf dpdk-2.0.0.tar.gz
cd dpdk-2.0.0/
make config T=x86_64-native-linuxapp-gcc && make

cd ~/GENI_VT/
sudo ./collect_sys_info.sh

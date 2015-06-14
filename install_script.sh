#!/bin/bash

# install useful tools
sudo apt-get update 
sudo apt-get install -y vim ethtool screen qemu-kvm exuberant-ctags apparmor bridge-utils unzip
# NOTE: apparmor is to enable docker; 
# http://stackoverflow.com/questions/29294286/fata0000-get-http-var-run-docker-sock-v1-17-version-dial-unix-var-run-doc

### Install experiment software
# git clone git://dpdk.org/apps/pktgen-dpdk
# git clone git://
# wget http://dpdk.org/browse/dpdk/snapshot/dpdk-2.0.0.tar.gz

# TODO make it an option to install docker


# install Docker
DOCKER=$(which docker)

if [[ -z $DOCKER ]];
then
    wget -qO- https://get.docker.com/ | sh
    sudo usermod -aG docker mattwel
    sudo service docker start
fi

sudo docker run hello-world

# make links to start scripts
ln -s ~/GENI_VT/startvm.sh ~/images/startvm.sh

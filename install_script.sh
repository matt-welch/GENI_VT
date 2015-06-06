#!/bin/bash
# make results directories
mkdir -p ~/results/logs/

# install useful tools
sudo apt-get update 
sudo apt-get install -y vim ethtool screen qemu-kvm exuberant-ctags 

# install Docker
DOCKER=$(which docker)

if [[ -z $DOCKER ]];
then
    wget -qO- https://get.docker.com/ | sh
fi


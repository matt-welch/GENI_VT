#!/bin/bash
# make results directories
mkdir -p ~/results/logs/

# install useful tools
sudo apt-get update 
sudo apt-get install -y vim ethtool screen qemu-kvm exuberant-ctags apparmor
# apparmor is to enable docker

# install Docker
DOCKER=$(which docker)

if [[ -z $DOCKER ]];
then
    wget -qO- https://get.docker.com/ | sh
    sudo usermod -aG docker mattwel
    sudo service docker start
fi

sudo docker run hello-world

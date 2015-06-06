#!/bin/bash
# make results directories
mkdir -p ~/results/logs/

# install useful tools
sudo apt-get update 
sudo apt-get install -y vim ethtool screen qemu-kvm exuberant-ctags apparmor
# apparmor is to enable docker 
# http://stackoverflow.com/questions/29294286/fata0000-get-http-var-run-docker-sock-v1-17-version-dial-unix-var-run-doc

# install Docker
DOCKER=$(which docker)

if [[ -z $DOCKER ]];
then
    wget -qO- https://get.docker.com/ | sh
    sudo usermod -aG docker mattwel
    sudo service docker start
fi

sudo docker run hello-world

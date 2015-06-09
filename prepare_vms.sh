#!/bin/bash
# prepare VMS

mkdir -p ~/images/
cd ~/images/
#qemu-img create -f qcow2 ubuntu.img 3G
#wget http://releases.ubuntu.com/trusty/ubuntu-14.04.2-server-amd64.iso

ln -s ~/GENI_VT/startvm.sh ~/images/startvm.sh

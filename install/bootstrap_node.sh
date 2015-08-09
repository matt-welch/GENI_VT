#!/bin/bash
# bootstrap_node.sh 
# this script makes directories and organizes data copied to newly-booted node

echo "Installing git keys..."
mv keys/* ~/.ssh/

echo "Making results directory..."
mkdir -p ~/results/logs/
echo "Making images directory..."
mkdir -p ~/images

source clone_GENI_VT.sh
cloneGENI

TARBALL="~/images/ubuntu.tar.bz2"
if [[ -f $TARBALL ]]; then
    echo "Extracting VM image..."
    tar xvf $TARBALL -C ~/images
fi


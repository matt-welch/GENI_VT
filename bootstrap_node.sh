#!/bin/bash

echo "Installing git keys..."
mv keys/* ~/.ssh/

echo "Making results directory..."
mkdir -p ~/results/logs/

echo "Cloning into GENI_VT..."
git clone git@github.com:matt-welch/GENI_VT.git
cd GENI_VT
git submodule init
git submodule update

# prepare dotfiles
cd daffy-dotfiles/
./install.sh

# install necessary packages and tools
./install_script.sh

# extract VM image 
echo "Making images directory..."
mkdir -p ~/images

TARBALL="~/images/ubuntu.tar.bz2"
if [[ -f $TARBALL ]]; then
    echo "Extracting VM image..."
    tar xvf $TARBALL -C ~/images
fi


#!/bin/bash

echo "Installing git keys..."
mv keys/* ~/.ssh/

echo "Making results directory..."
mkdir -p ~/results/logs/

echo "Making images directory..."
mkdir -p ~/images

echo "Extracting VM image..."
tar xvf ./images/ubuntu.tar.bz2  -C ~/images

echo "Cloning into GENI_VT..."
git clone git@github.com:matt-welch/GENI_VT.git
cd GENI_VT
git submodule init
git submodule update

cd daffy-dotfiles/
./install.sh


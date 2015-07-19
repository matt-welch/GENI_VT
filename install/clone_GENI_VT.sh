#!/bin/bash
echo "Cloning into GENI_VT..."
git clone git@github.com:matt-welch/GENI_VT.git
cd GENI_VT
git submodule init
git submodule update

# prepare dotfiles
cd daffy-dotfiles/
./install.sh


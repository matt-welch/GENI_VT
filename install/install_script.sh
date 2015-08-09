#!/bin/bash

source installer_fcns.sh

echo "Beginning installation script: $0..."
installPackages
installKernel
# TODO need a switch here to control Docker and DPDK installation
collectSysInfo

printHeader
echo " $0 complete. "

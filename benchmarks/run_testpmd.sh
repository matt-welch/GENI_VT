#!/bin/bash

if [ -z "$GENI_HOME" ] ; then 
    echo "The GENI_HOME variable has not been defined."
fi

source ${GENI_HOME}/util/ids.sh
source ${GENI_HOME}/util/bash_colors.sh
source ${GENI_HOME}/util/sys_vars.sh

TESTPMD_HOME=$RTE_SDK/$RTE_TARGET/app
TESTPMD_BIN=$TESTPMD_HOME/testpmd 
EAL_ARGS=" -c 0x3e -n 4 --pci-whitelist $IF1_PCI --pci-whitelist $IF2_PCI "
# --eth-peer=X,M:M:M:M:M:M: set the MAC address of the X peer port (0 <= X < 32).
TESTPMD_ARGS=" -- -i - --eth-peer=0,${IF1_D_MAC} --eth-peer 1,${IF2_D_MAC} "
COMMAND="$TESTPMD_BIN $EAL_ARGS $TESTPMD_ARGS"

cd $TESTPMD_HOME 
echo Running testpmd: 
echo $COMMAND 
echo
$COMMAND



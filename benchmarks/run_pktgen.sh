#!/bin/bash

if [ -z "$GENI_HOME" ] ; then 
    echo "The GENI_HOME variable has not been defined."
fi

source ${GENI_HOME}/util/ids.sh
source ${GENI_HOME}/util/bash_colors.sh
source ${GENI_HOME}/util/sys_vars.sh

PKTGEN_HOME="${HOMEDIR}/dpdk/pktgen-2.9.1"
PKTGEN_BIN="${PKTGEN_HOME}/app/app/x86_64-native-linuxapp-gcc/pktgen"
EAL_ARGS=" -c 0x3e -n 4 --pci-whitelist $IF1_PCI --pci-whitelist $IF2_PCI "
PKTGEN_ARGS='-- -P -l pktgen.log -m "2:3.0,4:5.1"'
COMMAND="$PKTGEN_BIN $EAL_ARGS $PKTGEN_ARGS"

fcn_print_red "Execute the following command to start pktgen: "
echo $COMMAND
fcn_print_red "Note: "
echo
fcn_print_red "After starting pktgen, the screen text will turn black.
After the application has loaded (the Wind River log flashes by) ,
Type at the prompt: 
    $ theme start
and the black on black theme will switch to colors on black."

read -p "Do you want to start the command line above? (y/N): " -n 1 input

if [ "$input" == "y" -o "$input" == "Y" ] ; then 
    echo "Changing directory to ${PKTGEN_HOME} (so pktgen won't complain about LUA)"
    cd $PKTGEN_HOME 
    fcn_print_red "Starting pktgen ... "
    $COMMAND
fi
echo



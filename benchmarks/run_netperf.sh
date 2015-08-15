#!/bin/bash

source ${GENI_HOME}/util/ids.sh
source ${GENI_HOME}/util/bash_colors.sh

BENCHDIR=${GENI_HOME}/benchmarks/
SERVERIP="192.168.2.3"
SERVPORT="65432"
TCP_NODELAY="-D "

cd $BENCHDIR


function test_TCP_RR (){
    REQ_RESP_SIZE="-r 1,1 "
    COMMAND="./netperf -H $SERVERIP -p $SERVPORT -t TCP_RR  \
        -- $REQ_RESP_SIZE $TCP_NODELAY"
    echo $COMMAND
    $COMMAND
}


if [ "$0" == "/bin/bash" ] ; then 
    echo "Running function from bash..."
    exit
fi

FUNCLIST=$(grep "function test_" $0 | grep -v grep | sed -n -e 's/function \([a-zA-Z_]*\).*{/\1/p')
if [ -n "$FUNCLIST" ] ; then 
    PS3="Select a netperf test to run: "
    select RUNFUNC in $FUNCLIST; 
    do 
        echo "Running ${RUNFUNC}()... " && break
        echo "Invalid selection, aborting."
    done
    echo
    
    $RUNFUNC
fi
# probably running in bash after sourcing.  DO nothing

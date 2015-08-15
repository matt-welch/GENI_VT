#!/bin/bash

source ${GENI_HOME}/util/ids.sh
source ${GENI_HOME}/util/bash_colors.sh
source ${GENI_HOME}/util/sys_vars.sh

BENCHDIR=${GENI_HOME}/benchmarks/
SERVERIP="-H $IF2_D_IP "
SERVPORT="-p 65432 "
VERBOSITY="-v 4 "
CONFIDENCE="-I 99,5 "
GLOBAL_OPTS=" $VERBOSITY -j "

cd $BENCHDIR


function test_TCP_RR (){
    REQ_RESP_SIZE="-r 1,1 "
    TCP_NODELAY="-D "
    COMMAND="./netperf $SERVERIP $SERVPORT $GLOBAL_OPTS -t TCP_RR  \
        -- $REQ_RESP_SIZE $TCP_NODELAY"
    echo $COMMAND
    $COMMAND
}

function test_TCP_RR_CI (){
    REQ_RESP_SIZE="-r 1,1 "
    TCP_NODELAY="-D "
    COMMAND="./netperf $SERVERIP $SERVPORT $GLOBAL_OPTS $CONFIDENCE -t TCP_RR  \
        -- $REQ_RESP_SIZE $TCP_NODELAY"
    echo $COMMAND
    $COMMAND
}

function test_RR_reps () {
    NREPS=10
    for (( i=0 ; i<$NREPS ; i++ )) 
    do
        test_TCP_RR
    done
}

function test_STREAM () {
    COMMAND="./netperf $SERVERIP $SERVPORT $GLOBAL_OPTS  "
    echo $COMMAND
    $COMMAND
}


if [ "$0" == "/bin/bash" ] ; then 
    echo "Running function from bash..."
else
    
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
fi

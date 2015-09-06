#!/bin/bash 

SERVERIP=$1
PORT=$2 
VERBOSITY="-v 4 "
CONFIDENCE="-I 99,5 "
REQ_RESP_SIZE="-r 1,1 "
TCP_NODELAY="-D "
GLOBAL_OPTS=" -C $VERBOSITY -j "
REPS=20
CORE=0x2
function usage (){
    echo "Usage: $0 <SERVER_IP> <PORT>"
    exit
}

if (( $# < 2 )) ; then 
    usage
    exit
fi

# TCP stream bandwidth 
TESTNAME=TCP_STREAM
for (( i=1 ; i <= $REPS ; i++)) ; do 
    COMMAND="taskset $CORE ./netperf -H $SERVERIP -p $PORT $GLOBAL_OPTS -t $TESTNAME "
    echo $TESTNAME-$i/$REPS :: $COMMAND
    eval "$COMMAND"
done
COMMAND="taskset $CORE ./netperf -H $SERVERIP -p $PORT $GLOBAL_OPTS $CONFIDENCE -t $TESTNAME "
echo $TESTNAME-CI :: $COMMAND
eval "$COMMAND"


# TCP request/response
TESTNAME=TCP_RR
for (( i=1 ; i <= $REPS ; i++)) ; do 
    COMMAND="taskset $CORE ./netperf -H $SERVERIP -p $PORT $GLOBAL_OPTS -t $TESTNAME  \
        -- $REQ_RESP_SIZE $TCP_NODELAY"
    echo $TESTNAME-$i/$REPS :: $COMMAND
    eval "$COMMAND"
done
COMMAND="taskset $CORE ./netperf -H $SERVERIP -p $PORT $GLOBAL_OPTS $CONFIDENCE -t $TESTNAME  \
    -- $REQ_RESP_SIZE $TCP_NODELAY"
echo $TESTNAME-CI :: $COMMAND
eval "$COMMAND"



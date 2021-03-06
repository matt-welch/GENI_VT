#!/bin/bash 

SERVERIP=$1
PORT=$2 
VERBOSITY="-v 4 "
CONFIDENCE="-I 99,5 "
REQ_RESP_SIZE="-r 1,1 "
TCP_NODELAY="-D "
# show remote CPU usage, keep additional timing stats
GLOBAL_OPTS=" -C -j "
if [ -z "$3" ] ; then 
    REPS=1
else
    REPS=$3
fi
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
GLOBAL_OPTS="$GLOBAL_OPTS $VERBOSITY"
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



#!/bin/bash
if [ -z "$1" ] ; then 
    SERVER="192.168.3.1"
else
    SERVER="$1"
fi
echo Server IP = $SERVER
SOCKET=0
if [ -n "$2" ] ; then 
    SOCKET="$2"
fi
echo Client socket = $SOCKET

PORT=65432
REPS=20
if [[ "$SOCKET" == 0 ]] ; then 
    CPU_PINNING="taskset 0x2 " # local socket, cpu 1 (cpu 2/12)
else
    CPU_PINNING="taskset 0x10 " # remote socket, cpu 1 (cpu 8/12)
fi

TEST="TCP_STREAM"
echo "#Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    echo "#$TEST, $SERVER, Rep $(( i + 1 )) of $REPS: "
    $CPU_PINNING  ./netperf -H $SERVER -p $PORT -t $TEST
done

TEST="UDP_STREAM"
echo "#Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    echo "#$TEST, $SERVER, Rep $(( i + 1 )) of $REPS: "
    $CPU_PINNING  ./netperf -H $SERVER -p $PORT -t $TEST -v 2 
done

TEST="TCP_RR"
echo "#Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    echo "#$TEST, $SERVER, Rep $(( i + 1 )) of $REPS: "
    $CPU_PINNING ./netperf -H $SERVER -p $PORT -t $TEST -v 4 -- -r 1,1
done

TEST="UDP_RR"
echo "#Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    echo "#$TEST, $SERVER, Rep $(( i + 1 )) of $REPS: "
    $CPU_PINNING ./netperf -H $SERVER -p $PORT -t $TEST -v 2 -- -r 1,1
done

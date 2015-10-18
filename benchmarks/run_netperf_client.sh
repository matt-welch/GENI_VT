#!/bin/bash
if [ -z "$1" ] ; then 
    SERVER="192.168.3.1"
else
    SERVER="$1"
fi
PORT=65432
REPS=20

TEST="TCP_STREAM"
echo "#Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    echo "#$TEST, $SERVER, Rep $(( i + 1 )) of $REPS: "
    taskset 0x2 ./netperf -H $SERVER -p $PORT -t $TEST
done

TEST="UDP_STREAM"
echo "#Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    echo "#$TEST, $SERVER, Rep $(( i + 1 )) of $REPS: "
    taskset 0x2 ./netperf -H $SERVER -p $PORT -t $TEST -v 2 
done

TEST="TCP_RR"
echo "#Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    echo "#$TEST, $SERVER, Rep $(( i + 1 )) of $REPS: "
    taskset 0x2 ./netperf -H $SERVER -p $PORT -t $TEST -v 4 -- -r 1,1
done

TEST="UDP_RR"
echo "#Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    echo "#$TEST, $SERVER, Rep $(( i + 1 )) of $REPS: "
    taskset 0x2 ./netperf -H $SERVER -p $PORT -t $TEST -v 2 -- -r 1,1
done

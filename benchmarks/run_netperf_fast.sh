#!/bin/bash
SERVER="192.168.42.242"
PORT=65432
REPS=20

echo "TCP_STREAM"
for (( i=0; i<"$REPS"; i++ )) ; do
    ./netperf -H $SERVER -p $PORT -t TCP_STREAM
done

echo "TCP_RR"
for (( i=0; i<"$REPS"; i++ )) ; do
    ./netperf -H $SERVER -p $PORT -t TCP_RR -v 4 -- -r 1,1
done

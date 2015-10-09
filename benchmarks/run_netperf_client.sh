#!/bin/bash
set -e  # set to error out if a variable is unset
if [ -z "$1" ] ; then 
    SERVER="192.168.42.242"
else
    SERVER="$1"
fi
PORT=65432
REPS=20

TEST="TCP_STREAM"
echo "Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    ./netperf -H $SERVER -p $PORT -t $TEST
done

TEST="TCP_RR"
echo "Running netperf::${TEST} @ $(date): ${SERVER}:${PORT}"
for (( i=0; i<"$REPS"; i++ )) ; do
    ./netperf -H $SERVER -p $PORT -t $TEST -v 4 -- -r 1,1
done

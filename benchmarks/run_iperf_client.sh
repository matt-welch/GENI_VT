#!/bin/bash 
set -e  # set to error out if a variable is unset
SERVER="192.168.42.242"
PORT="5201" # standard port 
TARGET_BANDWIDTH="" # "-b 20G"
SERVERSTATS="--get-server-output" 
REPS=20

# run standard iperf test 
TEST="TCP Bandwidth"
echo "Running iperf3::${TEST} @ $(date): ${SERVER}:${PORT}, ($TARGET_BANDWIDTH) "
for (( i=0; i<"$REPS"; i++ )) ; do
    ./iperf3 -c $SERVER -p $PORT $SERVERSTATS $TARGET_BANDWIDTH
done

# run iperf with udp
TEST="UDP Bandwidth"
echo "Running iperf3::${TEST} @ $(date): ${SERVER}:${PORT}, ($TARGET_BANDWIDTH) "
for (( i=0; i<"$REPS"; i++ )) ; do
    ./iperf3 -c $SERVER -p $PORT $SERVERSTATS -u $TARGET_BANDWIDTH
done

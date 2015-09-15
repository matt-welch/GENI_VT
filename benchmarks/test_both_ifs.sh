#!/bin/bash
PORT=65432
BRIDGE_IF=192.168.42.254
DIRECT_PHYS_IF=192.168.3.1
NUM_REPS=20
SERVER_ADDR=$BRIDGE_IF
echo Beginning netperf testing on bridged IF ${SERVER_ADDR}:${PORT} at $(date)
./replicate_netperf.sh $SERVER_ADDR $PORT $NUM_REPS
echo -e "\n\n\n\n"

SERVER_ADDR=$DIRECT_PHYS_IF
echo Beginning netperf testing on direct physical IF ${SERVER_ADDR}:${PORT} at $(date)
./replicate_netperf.sh $SERVER_ADDR $PORT $NUM_REPS

echo -e "\nTesting complete at $(date)"

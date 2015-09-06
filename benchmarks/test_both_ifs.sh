#!/bin/bash
PORT=65432
BRIDGE_IF=192.168.3.21
DIRECT_PHYS_IF=192.168.2.21

SERVER_ADDR=$BRIDGE_IF
echo Beginning netperf testing on bridged IF ${SERVER_ADDR}:${PORT} at $(date)
./replicate_netperf.sh $SERVER_ADDR $PORT
echo -e "\n\n\n\n"

SERVER_ADDR=$DIRECT_PHYS_IF
echo Beginning netperf testing on direct physical IF ${SERVER_ADDR}:${PORT} at $(date)
./replicate_netperf.sh $SERVER_ADDR $PORT

echo -e "\nTesting complete at $(date)"

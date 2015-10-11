#!/bin/bash
TEST=netperf
CLNTTYPE=remote
SERVTYPE=cont

SERVER_IP=192.168.42.246
IF_TYPE=br
./run_netperf_client.sh $SERVER_IP | tee /root/results/3.18.20/${TEST}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 

SERVER_IP=192.168.3.1
IF_TYPE=phy
./run_netperf_client.sh $SERVER_IP | tee /root/results/3.18.20/${TEST}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat


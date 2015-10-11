#!/bin/bash
TEST=iperf
CLNTTYPE=remote
SERVTYPE=cont

SERVER_IP=192.168.42.246
IF_TYPE=br
./run_iperf_client.sh $SERVER_IP | tee /root/results/3.18.20/${TEST}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 

SERVER_IP=192.168.3.1
IF_TYPE=phy
./run_iperf_client.sh $SERVER_IP | tee /root/results/3.18.20/${TEST}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat


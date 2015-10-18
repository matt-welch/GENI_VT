#!/bin/bash
TEST=netperf
CLNTTYPE=cont
SERVTYPE=cont

SERVER_IP=192.168.42.249
IF_TYPE=br
SOCKET=0
./run_netperf_client.sh $SERVER_IP $SOCKET | tee /root/results/3.18.20/${TEST}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}-socket${SOCKET}.dat 
SOCKET=1
./run_netperf_client.sh $SERVER_IP $SOCKET | tee /root/results/3.18.20/${TEST}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}-socket${SOCKET}.dat 

#SERVER_IP=192.168.3.1
#IF_TYPE=phy
#./run_netperf_client.sh $SERVER_IP | tee /root/results/3.18.20/${TEST}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat
#

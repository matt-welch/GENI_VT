#!/bin/bash
CLNTTYPE=remote
SERVTYPE=kvm
KERNTYPE=rt
if [ "$KERNTYPE" == "rt" ] ; then 
    DATADIR=/root/results/3.18.20-rt18
else
    DATADIR=/root/results/3.18.20
fi
echo "Datadir = $DATADIR"

SERVER_IP=192.168.2.21
IF_TYPE=brg

TEST=netperf
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
./run_netperf_client.sh $SERVER_IP | tee $FILENAME
TEST=icmp
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
taskset 0x2 ping $SERVER_IP -c 100 | tee $DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 

SERVER_IP=192.168.3.21
IF_TYPE=phy

TEST=netperf
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
./run_netperf_client.sh $SERVER_IP | tee $DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat

TEST=icmp
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
taskset 0x2 ping $SERVER_IP -c 100 | tee $DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 

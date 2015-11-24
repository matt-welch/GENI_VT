#!/bin/bash
CLNTTYPE=rem_udp_only
SERVTYPE=dkr
KERNTYPE=rt
if [ "$KERNTYPE" == "rt" ] ; then 
    DATADIR=/root/results/3.18.20-rt18
else
    DATADIR=/root/results/3.18.20
fi
mkdir -p $DATADIR
echo "Datadir = $DATADIR"

SERVER_IP=192.168.42.242
IF_TYPE=brg

TEST=netperf
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
./run_netperf_client.sh $SERVER_IP | tee $FILENAME
TEST=icmp
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
taskset 0x2 ping $SERVER_IP -c 100 | tee $DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 

#SERVER_IP=192.168.3.1
#IF_TYPE=phy
#
#TEST=netperf
#FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
#echo Saving data to $FILENAME
#./run_netperf_client.sh $SERVER_IP | tee $DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat
#
#TEST=icmp
#FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
#echo Saving data to $FILENAME
#taskset 0x2 ping $SERVER_IP -c 100 | tee $DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 

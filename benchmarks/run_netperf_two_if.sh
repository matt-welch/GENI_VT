#!/bin/bash
SERVER_HOST="10.2.63.79"
RTKERN=$(ssh root@${SERVER_HOST} cat /proc/cmdline | grep rt)
if [ -z "$RTKERN" ] ; then 
    # host is NOT running rt kernel, use std
    KERNTYPE=std
    DATADIR=/root/results/3.18.20
else
    echo "Host kernel cmd line: $RTKERN"
    KERNTYPE=rt
    DATADIR=/root/results/3.18.20-rt18
fi
mkdir -p $DATADIR
echo "Datadir = $DATADIR"

# find SERVTYPE: ssh to host since container doesn't run ssh-server
QEMU_RUNNING=$(ssh root@${SERVER_HOST} ps -ef | grep qemu)
if [ -z "$QEMU_RUNNING" ] ; then 
   # must be docker since no qemu process is running
    SERVTYPE=dkr
    BRG_IF=192.168.42.242
    PHY_IF=192.168.3.1
else
    SERVTYPE=kvm
    BRG_IF=192.168.2.21
    PHY_IF=192.168.3.21
fi

# set CLNTTYPE to describe any other configurations
CLNTTYPE=udp1472


SERVER_IP=$BRG_IF
IF_TYPE=brg
TEST=netperf
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
./run_netperf_client.sh $SERVER_IP | tee $FILENAME

TEST=icmp
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
taskset 0x2 ping $SERVER_IP -c 100 | tee $DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 

SERVER_IP=$PHY_IF
IF_TYPE=phy
TEST=netperf
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
./run_netperf_client.sh $SERVER_IP | tee $DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat

TEST=icmp
FILENAME=$DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 
echo Saving data to $FILENAME
taskset 0x2 ping $SERVER_IP -c 100 | tee $DATADIR/${TEST}-${KERNTYPE}-${CLNTTYPE}-${SERVTYPE}-${IF_TYPE}.dat 

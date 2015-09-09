#!/bin/bash
REPO="bench/network"
TAG="netperf"
NAME="netserver"
RUN_CMD="/root/netserver -p 65432 -D"
if [ $(uname -r) = "3.18.20-rt18" ] ; then 
    PINNING=" --cpuset-cpus=1-4 --cpuset-mems=0"
else
    PINNING=""
fi

docker run --rm=true $PINNING --name=${NAME} ${REPO}:${TAG} $RUN_CMD
# have container ech out its IP address for the netperf client to connect to  - dcker inspect!



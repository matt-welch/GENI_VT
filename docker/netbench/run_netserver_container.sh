#!/bin/bash
REPO="bench/network"
TAG="netperf"
NAME="netserver"
HWADDR="de:ad:be:ef:42:01"
MAC="--mac-address $HWADDR "
RUN_CMD="/bin/bash"
if [[ $(uname -r) == *"rt18"* ]] ; then 
    RUN_CMD="taskset 0x2 /root/netserver -p 65432 -D"
    PINNING=" --cpuset-cpus=1-4 --cpuset-mems=0"
else
    RUN_CMD="/root/netserver -p 65432 -D"
    PINNING=""
fi
RUN_CMD="taskset 0x2 /root/netserver -p 65432 -D"
PINNING=" --cpuset-cpus=1-4 --cpuset-mems=0"

docker run --rm=true -it $MAC $PINNING --name=${NAME} ${REPO}:${TAG} $RUN_CMD
# have container ech out its IP address for the netperf client to connect to  - dcker inspect!



#!/bin/bash
REPO="bench/network"
TAG="netbench"
NAME="netbench"
HWADDR="de:ad:be:ef:42:02"
MAC="" #--mac-address $HWADDR "
RUN_CMD="/bin/bash"
if [[ $(uname -r) == *"rt18"* ]] ; then 
    PINNING=" --cpuset-cpus=1-4 --cpuset-mems=0"
    echo "Realtime kernel, Setting pinning to : $PINNING"
else
    PINNING=""
fi

docker run --rm=true -it $MAC $PINNING --name=${NAME} ${REPO}:${TAG} $RUN_CMD



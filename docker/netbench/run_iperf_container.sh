#!/bin/bash
REPO="bench/network"
TAG="netperf"
NAME="iperfclient"
HWADDR="de:ad:be:ef:42:01"
MAC="--mac-address $HWADDR "
RUN_CMD="/bin/bash"
HOST_VOLUME="/home/matt/GENI_VT/benchmarks/"
MOUNT_POINT="/root/benchmarks/"
BENCH_MOUNT="-v ${HOST_VOLUME}:${MOUNT_POINT} "
if [[ $(uname -r) == *"rt18"* ]] ; then 
    PINNING=" --cpuset-cpus=1-4 --cpuset-mems=0"
else
    PINNING=""
fi

docker run --rm=true -it $MAC $PINNING --name=${NAME} $BENCH_MOUNT ${REPO}:${TAG} $RUN_CMD



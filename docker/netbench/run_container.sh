#!/bin/bash
REPO="bench/network"
TAG="netbench"
RUN_CMD="/bin/bash"
if [[ $(uname -r) == *"rt18"* ]] ; then 
    PINNING=" --cpuset-cpus=1-4 --cpuset-mems=0"
    echo "Realtime kernel, Setting pinning to : $PINNING"
else
    PINNING=""
fi

docker run --rm=true -it $PINNING --name=${NAME} ${REPO}:${TAG} $RUN_CMD



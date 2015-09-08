#!/bin/bash
REPO="bench/network"
TAG="netperf"
NAME="netperf-CRAN"
RUN_CMD="/root/netserver -p 65432 -D"

docker run --rm=true --name=${NAME} ${REPO}:${TAG} $RUN_CMD
# have container ech out its IP address for the netperf client to connect to  - dcker inspect!



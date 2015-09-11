#!/bin/bash
# docker build [OPTIONS] PATH | URL | -
REPO="bench/network"
TAG="netperf"
DOCKERFILE="Dockerfile.netbench"

echo Building ${REPO}:${TAG} $(grep FROM $DOCKERFILE)
docker build -f $DOCKERFILE \
    --tag="${REPO}:${TAG}" \
    --cpuset-cpus=1-4 .

# if the above built correctly, we should have a matching image
docker images | grep $REPO | grep $TAG --color



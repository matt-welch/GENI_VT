#!/bin/bash
# docker build [OPTIONS] PATH | URL | -
REPO="bench/base"
TAG="ubuntu"
DOCKERFILE="Dockerfile.base.ubuntu"

echo Building ${REPO}:${TAG} $(grep FROM $DOCKERFILE)
docker build -f $DOCKERFILE \
    --tag="${REPO}:${TAG}" \
    --cpuset-cpus=1-4 .

# if the above built correctly, we should have a matching image
docker images | grep $REPO | grep $TAG --color


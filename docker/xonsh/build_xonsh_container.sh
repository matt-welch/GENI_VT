
#!/bin/bash
# docker build [OPTIONS] PATH | URL | -
REPO="tools"
TAG="xonsh"
DOCKERFILE="Dockerfile.xonsh"
BUILDDIR=$(pwd)

echo "Building ${REPO}:${TAG} $(grep FROM $DOCKERFILE) in $BUILDDIR ..."
docker build -f $DOCKERFILE \
    --tag="${REPO}:${TAG}" $BUILDDIR

# if the above built correctly, we should have a matching image
docker images | grep $REPO | grep $TAG --color


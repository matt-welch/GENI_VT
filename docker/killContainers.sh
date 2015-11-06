#!/bin/bash

CIDS=$(docker ps -a | grep netsrv | cut -d ' ' -f 1)

echo "Removing containers ... "
for CID in $CIDS; do 
    CNAME=$(docker inspect $CID | grep Name | grep "/" | cut -d '"' -f 4)
    echo "Stopping container $CNAME"
    docker stop $CID
    echo "Removing container $CNAME"
    docker rm $CID
done

echo "Removing bridges ... "
BRIDGES=$(brctl show | grep ^cbr[[:digit:]] | awk '{print $1}')
for CBR in $BRIDGES; do 
    echo "Removing container bridge: $CBR"
    ip link set $CBR down 
    brctl delbr $CBR
done

# Clean up dangling symlinks in /var/run/netns
NETNS_DIR="/var/run/netns"
echo "Cleaning up symlinks in $NETNS_DIR ..."
find -L $NETNS_DIR -type l -delete

# remove veth interfaces stuck in host netns
HOSTIF=ethUS
if [ -n "$(ip addr show | grep $HOSTIF)" ] ; then 
    echo "Removing $HOSTIF veth link ..."
    ip link del $HOSTIF
fi

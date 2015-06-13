#!/bin/bash

FILE=bootstrap_pkg.tar.bz2 
KEY="/home/mwelch/.ssh/id_hp_ubuntu_rsa"
USER="mattwel"

# enter the names of the nodes in quesion: 
# select which nodes to copy to
NODE_IX=1
if [[ -z $1 ]] 
then
    NODE_IX=$1
fi
HOST=$(cat nodes.lst | cut -d ' ' -f ${NODE_IX})
TARGETDIR="/users/${USER}/"

# scp {keys/, VM image tarball, bootstrap_node.sh}
if [[ -z $HOST ]] ; then
    echo HOST is empty
fi

echo "Transferring $FILE to ${USER}@${HOST}:${TARGETDIR}"
scp -i $KEY -v $FILE ${USER}@${HOST}:${TARGETDIR}

echo "Transfer complete. SSH to ${USER}@${HOST}:${TARGETDIR}"
ssh -i $KEY -v ${USER}@${HOST} 

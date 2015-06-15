#!/bin/bash

FILE=package.tar.bz2 
KEY="/home/mwelch/.ssh/id_hp_ubuntu_rsa"
USER="mattwel"

# enter the names of the nodes in quesion: 
# select which nodes to copy to
NODE_IX=1
if [[ -n $1 ]] ; then
    NODE_IX=$1
else
    echo "Call ./$0 <NODE>"
fi
HOST=$(cat nodes.lst | cut -d ' ' -f ${NODE_IX})
TARGETDIR="/users/${USER}/"

# scp {keys/, VM image tarball, bootstrap_node.sh}
if [[ -z $HOST ]] ; then
    echo HOST is empty
fi

echo "Transferring $FILE to ${USER}@${HOST}:${TARGETDIR}"
scp -i $KEY -v $FILE ${USER}@${HOST}:${TARGETDIR}

echo "Transfer complete. SSH to ${USER}@${HOST}:${TARGETDIR} & extract package..."
ssh -i $KEY -v ${USER}@${HOST} 'tar xvf package.tar.bz2'

echo "Package extracted. SSH to ${USER}@${HOST}:${TARGETDIR} & install..."
ssh -i $KEY -v ${USER}@${HOST} 'sudo ./bootstrap_node.sh'

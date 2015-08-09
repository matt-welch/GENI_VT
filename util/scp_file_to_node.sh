#!/bin/bash
# scp_file_to_node.sh
# ssh-copy first argument ($1) to node ($2)

FILE=$1 
KEY="/home/matt/.ssh/id_hp_ubuntu_rsa"
USER="mattwel"
NODE_IX=1
if [[ -n $2 ]] 
then
    NODE_IX=$2
fi

HOST=$(cat nodes.lst | cut -d ' ' -f ${NODE_IX})
TARGETDIR="/users/${USER}/"

echo "Transferring $FILE to ${USER}@${HOST}:${TARGETDIR}"
scp -i $KEY -v $FILE ${USER}@${HOST}:${TARGETDIR}

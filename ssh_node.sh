#!/bin/bash

KEY="/home/mwelch/.ssh/id_hp_ubuntu_rsa"
USER="mattwel"
NODE_IX=1
if [[ -n $1 ]] ; then
    NODE_IX=$1
fi

HOST=$(cat nodes.lst | cut -d ' ' -f ${NODE_IX})
echo "Connecting to ${HOST} as $USER..."

COMMAND="ssh -v -i $KEY ${USER}@${HOST}"
echo $COMMAND


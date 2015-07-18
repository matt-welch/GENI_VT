#!/bin/bash

KEY="/home/matt/.ssh/id_hp_ubuntu_rsa"
USER="mattwel"
NODE_IX=1
if [[ -n $1 ]] ; then
    NODE_IX=$1
fi

HOST=$( cut -d ' ' -f ${NODE_IX} nodes.lst )
echo "Connecting to ${HOST} as $USER..."

COMMAND="ssh -v -i $KEY ${USER}@${HOST}"
echo $COMMAND
read -p "Do you want to connect to the above address? (y/n): " -n 1 input
echo
echo

if [ "$input" == "y" -o "$input" == "Y" ]
then
    echo "Attempting connection at $(date)"
    ssh -v -i $KEY ${USER}@${HOST}
else
    echo "User entered $input.  Enter 'Y/y' to connect."
fi



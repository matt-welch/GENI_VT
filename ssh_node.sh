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
echo -n "Do you want to connect to the above address? "
read -n 1 input

if [ "$input" == "y" -o "$input" == "Y" ]
then
    ssh -v -i $KEY ${USER}@${HOST}
else
    echo "User entered $input.  Enter 'Y/y' to connect."
fi



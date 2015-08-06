#!/bin/bash

source util/bash_colors.sh

KEY="/home/matt/.ssh/id_hp_ubuntu_rsa"
USER="mattwel"
NODE_IX=1
if [[ -n "$1" ]] 
then
    if [[ "$1" = "0" ]] 
    then
        # this mode will attempt to connect to 1st node without prompt
        fcn_print_red "Using node1"
        NODE_IX=1
    else
        NODE_IX=$1
    fi
fi

HOST=$( cut -d ' ' -f ${NODE_IX} nodes.lst )
echo "Connecting to $(fcn_print_red ${HOST}) as $(fcn_print_red $USER)..."

COMMAND="ssh -v -i $KEY ${USER}@${HOST}"
fcn_print_red "$COMMAND \n"
if [ "$1" =  "0" ] 
then
    input=Y
else
    read -p "Do you want to connect to the above address? (y/n): " -n 1 input
fi
echo
echo

if [ "$input" == "y" -o "$input" == "Y" ]
then
    echo "Attempting connection at $(fcn_print_red '$(date)') "
    ssh -v -i $KEY ${USER}@${HOST}
else
    echo "User entered $(fcn_print_red "$input").  Enter 'Y/y' to connect."
fi



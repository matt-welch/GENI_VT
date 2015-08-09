#!/bin/bash
function parseNode() {
    # enter the names of the nodes in quesion: 
    # select which nodes to copy to
    NODE_IX=1
    if [[ -n $1 ]] ; then
        NODE_IX=$1
    else
        echo "Usage:  ./$0 <NODE>"
    fi
    HOST=$(cat ../util/nodes.lst | cut -d ' ' -f ${NODE_IX})
    
    if [[ -z $HOST ]] ; then
        echo HOST is empty
        exit
    fi
}


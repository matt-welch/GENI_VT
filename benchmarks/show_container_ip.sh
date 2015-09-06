#!/bin/bash

CONTAINER_NAME=$1
if [ -z $CONTAINER_NAME ] ; then 
    echo
    echo Usage: $0 CONTAINER_NAME 
    echo
    echo Running Containers: 
    docker ps 
    echo
    exit
fi

docker exec $CONTAINER_NAME ifconfig -a 


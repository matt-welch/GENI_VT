#!/bin/bash
CIDS=$(docker ps | grep -v "CONTAINER" | awk '{print $1}')
for i in $CIDS; do 
    NAME=$(docker inspect -f '{{.Name}}' $i)
    IMAGE=$(docker inspect -f '{{.Config.Image}}' $i)
    echo -e "\nContainer ($i):$NAME from $IMAGE : " 
    docker exec $i ps -ef 
done
echo 

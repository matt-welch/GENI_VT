#!/bin/bash
for i in $(docker ps -a | grep Exited | awk '{print $1 }')
do
	docker rm $i
done

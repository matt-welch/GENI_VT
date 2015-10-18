#!/bin/bash

for FILE in $(ls iperf*.dat); do 
    OUTPUT="${FILE}.summary"
    if [ -f "$OUTPUT" ] ; then 
        rm $OUTPUT
    fi
    IPADDR=$(head "$FILE" | grep Connecting | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
    PORT=$(head $FILE | grep Connecting | grep -o "[0-9]*$")
    echo "### iperf TCP bandwidth, ${IPADDR}:${PORT} ### " >> $OUTPUT
    grep "Server output" -B 4 $FILE | grep receiver >> $OUTPUT
    echo >> $OUTPUT
    echo "### iperf UDP bandwidth, ${IPADDR}:${PORT} ### " >> $OUTPUT
    grep "Server output" -B 4 $FILE | grep datagrams -B 1 | grep " ms" >> $OUTPUT
    echo >> $OUTPUT
done

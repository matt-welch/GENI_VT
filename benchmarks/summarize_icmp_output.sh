#!/bin/bash

#FILE="ICMP-host-cont-brg-std.dat"; cat $FILE | awk '{print $7}' | cut -d '=' -f 2 > ${FILE}.column

# use the following loop for recent data
for FILE in $(ls icmp*.dat); do 
    OUTPUT="${FILE}.column"
    if [ -f "$OUTPUT" ] ; then 
        rm $OUTPUT
    fi
    echo "### ICMP LAT ### " >> $OUTPUT
    cat $FILE | awk '{print $7}' | cut -d '=' -f 2 | grep [[:digit:]] >> $OUTPUT
    echo >> $OUTPUT
done

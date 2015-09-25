#!/bin/bash

# use the following loop for older format data
# for FILE in $(ls *.dat); do 
#     grep vtType $FILE -A 2 | grep -v "\-\-" | tail -n 24 > ${FILE}.summary
# done

# use the following loop for recent data
for FILE in $(ls netperf*.dat); do 
    OUTPUT="${FILE}.summary"
    if [ -f "$OUTPUT" ] ; then 
        rm $OUTPUT
    fi
    echo "### netperf  TCP bandwidth ### " >> $OUTPUT
    grep "TCP STREAM" -A 6 $FILE | grep "^ 8" >> $OUTPUT
    echo >> $OUTPUT
    echo "### netperf  TCP Request/Response ### " >> $OUTPUT
    grep "TCP REQUEST/RESPONSE TEST" -A 6 $FILE | grep "^[ ]*8" >> $OUTPUT
    echo >> $OUTPUT
done

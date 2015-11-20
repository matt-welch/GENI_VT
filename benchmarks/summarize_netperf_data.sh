#!/bin/bash

for FILE in $(ls *.dat); do 
    OUTPUT="${FILE}.summary"
    rm $OUTPUT
    echo "Filename: $FILE" >> $OUTPUT
    TEST="TCP REQUEST/RESPONSE TEST"
    echo $TEST >> $OUTPUT
    grep "$TEST" -A 6 $FILE | grep "^[ ]*8" >> $OUTPUT

    echo >> $OUTPUT
    TEST="TCP STREAM"
    echo $TEST >> $OUTPUT
    grep "$TEST" -A 6 $FILE | grep "^ 8" >> $OUTPUT
done

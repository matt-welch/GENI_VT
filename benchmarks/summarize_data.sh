#!/bin/bash

for FILE in $(ls *.dat); do 
    grep vtType $FILE -A 2 | grep -v "\-\-" | tail -n 24 > ${FILE}.summary
done

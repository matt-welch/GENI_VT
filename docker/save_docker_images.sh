#!/bin/bash

function parse_json () {
    FIELD="$1"
    if [ -z "$FIELD" ] ; then 
        FIELD='["NetworkSettings"]["IPAddress"]'
    fi
    #echo "Field=\"$FIELD\""
    OUTPUT=$(echo $JSON | python -c "import json,sys; obj=json.load(sys.stdin); print obj[0]${FIELD}")
    echo $OUTPUT
}

mkdir -p ./exports 
for image in $(docker images | grep intel | awk '{print $3 }')
do
    JSON=$(docker inspect $image)
    ID=$(parse_json '["Id"]')
    echo "ID=$ID"
    LABEL=$(parse_json '["ContainerConfig"]["Labels"]["benchmark"]')
    echo "Benchmark=$LABEL"
    if [ -n "$LABEL" ] ; then 
        docker save -o ${LABEL}.docker.tar $image
    fi
done

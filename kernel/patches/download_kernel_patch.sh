#!/bin/bash

function fcnSHAcheck() {
    REFFILE="sha256sums.asc"
    SHA256SUM=$(sha256sum $FILE)
    REFSUM=$(grep $FILE $REFFILE)
    if [[ -z $REFSUM ]] ; then
        echo "fcnSHAcheck>>> WARNING: no SHA256SUM refereance available for $FILE"
    else
        if [[ "$SHA256SUM" != "$REFSUM" ]] ; then 
            echo "fcnSHAcheck>>> ERROR: reference sum does not match for $FILE vs $REFFILE."
        else
            echo "fcnSHAcheck>>> SUCCESS!: $FILE passes SHA256SUM check vs $REFFILE."
        fi
    fi
}

function downloadFiles() {
    SHAFILE="sha256sums.asc"
    echo "Downloading $FILENAME..."
    wget ${BASE_URL}${SHAFILE}
    echo $FILE_LIST
    for FILE in ${FILE_LIST[@]}; do 
        URL=${BASE_URL}${FILE} 
        echo "Downloading <${URL}> ..."
        if [[ ! -f "$FILE" ]] ; then 
            wget $URL 
        else
            echo "File present.  "
        fi
        fcnSHAcheck 
    done
}

function getVersionNums() {
    BASE_URL="https://www.kernel.org/pub/linux/kernel/projects/rt/${MAJVERSION}/"
    echo "Determining patch minor version for $MAJVERSION "
    sleep 1
    wget $BASE_URL -O $INDEX_FNAME 
    
    VERSION=$(grep "\-$MAJVERSION" $INDEX_FNAME  | cut -d "-" -f 2 | uniq)
    echo $VERSION
}

PATCH_CANDIDATES="3.10 3.12 3.14 3.18 4.0 4.1"
if [[ -z $1 ]] ; then 
    MAJVERSION="3.18"
else
    MAJVERSION=$1
fi

INDEX_FNAME="patch_index.html"
mkdir -p ./$MAJVERSION
cd       ./$MAJVERSION
rm -rf sha256sums.asc*
getVersionNums

BASE_URL="https://www.kernel.org/pub/linux/kernel/v3.x/"
INDEX_FNAME="kernel_index.html"
wget $BASE_URL -O $INDEX_FNAME 
FILE_LIST=$(grep ${VERSION} $INDEX_FNAME | cut -d "\"" -f 2 ) 
downloadFiles 

mkdir -p patch
cd patch
BASE_URL="https://www.kernel.org/pub/linux/kernel/projects/rt/${MAJVERSION}/"
INDEX_FNAME="patch_index.html"
wget $BASE_URL -O $INDEX_FNAME 
FILE_LIST=$(grep ${VERSION} $INDEX_FNAME | cut -d "\"" -f 2 ) 
downloadFiles 


#!/bin/bash
PATCH_BASE_URL="https://www.kernel.org/pub/linux/kernel/projects/rt/"
KERNL_BASE_URL="https://www.kernel.org/pub/linux/kernel/"

function fcnSHAcheck() {
    REFFILE="sha256sums.asc"
    SHA256SUM=$(sha256sum $FILE)
    REFSUM=$(grep $FILE $REFFILE)
    if [[ -z $REFSUM ]] ; then
        echo "${0}::${FUNCNAME[0]}:: >>> WARNING: no SHA256SUM refereance available for $FILE"
        echo
    else
        if [[ "$SHA256SUM" != "$REFSUM" ]] ; then 
            echo "${0}::${FUNCNAME[0]}:: >>> ERROR: reference sum does not match for $FILE vs $REFFILE."
            echo
        else
            echo "${0}::${FUNCNAME[0]}:: >>> SUCCESS!: $FILE passes SHA256SUM check vs $REFFILE."
            echo
        fi
    fi
}

function downloadFiles() {
    SHAFILE="sha256sums.asc"
    pwd
    mkdir -p logs
    echo "${0}::${FUNCNAME[0]}:: Downloading ${SHAFILE} ..."
    wget ${BASE_URL}${SHAFILE} -o logs/${SHAFILE}.log
    echo "Files to download: $FILE_LIST"
    for FILE in ${FILE_LIST[@]}; do 
        URL=${BASE_URL}${FILE} 
        if [[ ! -f "$FILE" ]] ; then 
            echo "Downloading ${URL} ..."
            wget $URL 
        else
            echo "${FILE} is already present, checking SHA256..."
        fi
        fcnSHAcheck 
    done
    echo
}

function getKernelVersions() {
    BASE_URL="https://www.kernel.org/pub/linux/kernel/projects/rt/${MAJVERSION}/"
    echo "${0}::${FUNCNAME[0]}:: Determining patch minor version for $MAJVERSION "
    pwd
    mkdir -p logs
    wget $BASE_URL -O $INDEX_FNAME -o logs/kernel_versions.log
    VERSION_LIST=$(grep "\-$MAJVERSION" $INDEX_FNAME  | cut -d "-" -f 2 | sort | uniq)
    PS3="Select a kernel version by typing the selection number:  "
    select VERSION in $VERSION_LIST; 
    do 
        echo "Version <$VERSION> of linux kernel matching <$MAJVERSION> selected" && break
        echo ">>> Invalid selection:"; 
    done
    echo
}

function selectMajVersion() {
    OUTPUT_FILE="patch_maj_vers.html"
    echo "${0}::${FUNCNAME[0]}::  getting major version numbers from $PATCH_BASE_URL ..."
    wget $PATCH_BASE_URL -O $OUTPUT_FILE -o patch_vers.log
    MAJLIST=$(grep href $OUTPUT_FILE | egrep -o '(3\.[0-9]+\.*[0-9]*|4\.[0-9]+\.*[0-9]*)' | uniq)
    pwd
    PS3="Select a preempt-RT version by typing the selection number:  "
    
    select MAJVERSION in $MAJLIST; 
    do 
        echo "Major Version of preempt-RT patch <$MAJVERSION> selected" && break
        echo ">>> Invalid selection:"; 
    done
    echo
}

PATCH_CANDIDATES="3.10 3.12 3.14 3.18 4.0 4.1"
if [[ -z $1 ]] ; then 
    selectMajVersion 
else
    MAJVERSION=$1
fi
echo "Kernel version $MAJVERSION selected"

INDEX_FNAME="patch_index.html"
mkdir -p ./$MAJVERSION/logs
cd       ./$MAJVERSION
rm -rf sha256sums.asc*
getKernelVersions

if [[ "$MAJVERSION" == "4."* ]] ; then 
    echo "Version 4 kernel selected"
    BASE_URL="${KERNL_BASE_URL}v4.x/"
elif [[ "$MAJVERSION" == "3."* ]] ; then 
    echo "Version 3 kernel selected"
    BASE_URL="${KERNL_BASE_URL}v3.x/"
fi

INDEX_FNAME="kernel_index.html"
wget $BASE_URL -O $INDEX_FNAME -o logs/${INDEX_FNAME}.log
FILE_LIST=$(grep ${VERSION} $INDEX_FNAME | cut -d "\"" -f 2 ) 
echo "FILE_LIST: <${FILE_LIST}>"
downloadFiles 

mkdir -p patch
cd patch
BASE_URL="${PATCH_BASE_URL}${MAJVERSION}/"
INDEX_FNAME="patch_index.html"
wget $BASE_URL -O $INDEX_FNAME 
FILE_LIST=$(grep ${VERSION} $INDEX_FNAME | cut -d "\"" -f 2 ) 
downloadFiles 


#!/bin/bash

source $GENI_HOME/util/bash_colors.sh
DEVICE_HOME="/sys/bus/pci/devices"

function usage () {
    echo "Usage: $0 <device BB:DD.F> [num_vfs] "
}

if [[ -z "$1" ]] ; then 
    usage
    exit 1 
fi

DEVICE_BDF="$1"
DEVICE_PATH="${DEVICE_HOME}/0000:${DEVICE_BDF}"
TARGET="$DEVICE_PATH/sriov_numvfs" 
SRIOV_NUMVFS=$(cat $TARGET)
SRIOV_TOTALVFS=$(cat $DEVICE_PATH/sriov_totalvfs)

function showVFs(){
    echo "$TARGET (current) = $SRIOV_NUMVFS"
    echo "$DEVICE_PATH/sriov_totalvfs (maximum) = $SRIOV_TOTALVFS "
}

function errorMsg(){
    fcn_print_red "ERROR: " nocr
    echo " The maximum number of Virtual functions for device $DEVICE_BDF may not exceed ${SRIOV_TOTALVFS}"
}

function selectNumVFs(){
    VF_LIST=$(seq  $SRIOV_TOTALVFS)
    showVFs
    echo "Select how many virtual functions (VFs) you want enabled: "
    PS3="Desired number of VFs for $DEVICE_BDF = "
    select DESIRED_NUMVFS in $VF_LIST; do  
        if [[ -n $DESIRED_NUMVFS ]] ; then 
            fcn_print_red "$DESIRED_NUMVFS" nocr 
            echo " virtual functions has been selected."
            return $DESIRED_NUMVFS
        else
            errorMsg
            exit 1
        fi
    done
}

function setNumVFs(){
    if (( "$SRIOV_NUMVFS" < "$DESIRED_NUMVFS" )) ; then 
        fcn_print_red "Before change:"
        showVFs
        read -p "Are you sure you want to change the sriov_numvfs for this device to $DESIRED_NUMVFS? (y/N): " -n 1 input
        echo
        if [[ "$input" == "y" ]] ; then 
            echo "Setting the number of SRIOV Virtual Functions for device $DEVICE_BDF to $DESIRED_NUMVFS ..."
            #echo $DESIRED_NUMVFS > $TARGET
            fcn_print_red "After change:"
            showVFs
        else
            echo "Aborted."
        fi
    else
        errorMsg
        exit 1
    fi
}

if [[ -z "$2" ]] ; then 
    # present selection on command line
    selectNumVFs 
else
    # use bash built-in character classes to verify numeric argument
    if [[ "$2" = *[[:digit:]]* ]]; then
        if (( "$2" < "1" )) ; then 
            fcn_print_red "The numvfs may not be negative. Aborting."
            exit 1 
        fi
    else
        fcn_print_red "The selected numvfs, \"$2\", is not numeric.  Aborting."
        exit 1
    fi
    DESIRED_NUMVFS="$2"
fi

# check if asking for too many vf's for this device
if (( "$DESIRED_NUMVFS" > "$SRIOV_TOTALVFS" )) ; then 
    errorMsg
else
    setNumVFs
fi



#!/bin/bash

source $GENI_HOME/util/bash_colors.sh

function check_hugepages() {
    NUM_HUGEPG=$(cat /proc/sys/vm/nr_hugepages)
    if [[ "$NUM_HUGEPG" == "0" ]] ; then 
        echo "Error: no hugepages available" 
        return 1 
    else
        echo "Hugepages=${NUM_HUGEPG}"
        return 0
    fi
}

function check_hugepage_status () {
    # this function is here for backward compatiibility
    check_hugepages 
}

function mount_hugetlbfs () {
    MOUNTPOINT=$(mount | grep hugetlbfs)
    if [ -z "$MOUNTPOINT" ] ; then 
        check_hugepages 
    
        MOUNTPOINT="/mnt/huge"
        sudo mkdir -p $MOUNTPOINT
        ISMOUNTED=$(mount | grep hugetlbfs)
    
        if [[ -z "$ISMOUNTED" ]] ; then 
            fcn_print_red "Mounting hugetlbfs ... "
            sudo mount -t hugetlbfs none $MOUNTPOINT
        fi
        fcn_print_red "HugeTLB FS mount: "
        mount | grep hugetlbfs
    else
        echo "Hugetlbfs already mounted at: $MOUNTPOINT"
    fi
}


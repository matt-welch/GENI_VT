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
    # this functino is here for nackward compatiibility
    check_hugepages 
}

function mount_hugetlbfs () {
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
}


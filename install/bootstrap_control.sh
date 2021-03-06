#!/bin/bash

FILE=package.tar.bz2 
source util/ids.sh # contains USER and KEY

# enter the names of the nodes in quesion: 
# select which nodes to copy to
NODE_IX=1
if [[ -n $1 ]] ; then
    NODE_IX=$1
else
    echo "Usage:  ./$0 <NODE>"
fi
HOST=$(cat nodes.lst | cut -d ' ' -f ${NODE_IX})
TARGETDIR=${HOMEDIR}

# scp {keys/, VM image tarball, bootstrap_node.sh}
if [[ -z $HOST ]] ; then
    echo HOST is empty
    exit
fi

# check if KVM is present.  else abort
KVM_MODS_FNAME=kvm_modules_node_${NODE_IX}
echo "Checking for kvm modules..."
ssh -i $KEY -v ${USER}@${HOST} 'lsmod' | grep kvm_intel > $KVM_MODS_FNAME 
if [ -z "$(cat $KVM_MODS_FNAME)" ]; then
    echo "No kvm modules available on the host...exiting"
    exit
fi
echo "Module kvm_intel is present and available on host."

if [[ "$2" == "fast" ]] ; then
    echo "Operating in FAST mode - not copying VM image..."
    FILE="keys_pkg.tar.bz2"
fi
# copy the package to the remote system
echo "Transferring $FILE to ${USER}@${HOST}:${TARGETDIR}"
scp -i $KEY -v $FILE ${USER}@${HOST}:${TARGETDIR}
echo "Transfer complete. SSH to ${USER}@${HOST}:${TARGETDIR} & extract package..."
ssh -i $KEY -v ${USER}@${HOST} "tar xvf ${FILE}"
## the following command often breaks because the git clone operation may ask for input
#echo "Package extracted. SSH to ${USER}@${HOST}:${TARGETDIR} & install..."
#ssh -i $KEY -v ${USER}@${HOST} 'sudo ./bootstrap_node.sh'

# connect to the node via ssh
echo "Connecting to ${USER}@${HOST}:${TARGETDIR} ..."
ssh -i $KEY -v ${USER}@${HOST} 


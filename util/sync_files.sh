#!/bin/bash
source ../util/parse_node.sh
source ../util/bash_colors.sh 
source ../util/ids.sh

# set HOST variable based on which node is selected through cmdline
parseNode $1

SOURCEDIR="keys_pkg.tar.bz2"
TARGETDIR="/users/${USER}/"


echo "Beginning rsync of $(fcn_print_red ${SOURCEDIR}) to \
    $(fcn_print_red ${USER}@${HOST}:${TARGETDIR}) ..."

rsync -avz -e "ssh -v -o -i ${KEY} StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null" --progress \
    $SOURCEDIR ${USER}@${HOST}:${TARGETDIR}


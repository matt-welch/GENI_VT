#!/bin/bash
if [[ "$1" == "small" ]]; then
    TARBALL="keys_pkg.tar.bz2"
    CONTENTS="keys/ bootstrap_node.sh "
else
    TARBALL="package.tar.bz2"
    CONTENTS="keys/ bootstrap_node.sh images/ubuntu.tar.bz2 "
fi
mv ${TARBALL} ${TARBALL}.bak

echo "Making $TARBALL containing {${CONTENTS}}..."
tar cvjf $TARBALL $CONTENTS 


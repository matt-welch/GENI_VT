#!/bin/bash
TARBALL="package.tar.bz2"
CONTENTS="./keys/ ./bootstrap_node.sh ../images/ubuntu.tar.bz2 "
mv ${TARBALL} ${TARBALL}.bak

echo "Making $TARBALL containing {${CONTENTS}}..."
tar cvjf $TARBALL $CONTENTS 


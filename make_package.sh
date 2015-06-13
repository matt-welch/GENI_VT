#!/bin/bash
TARBALL="bootstrap_pkg.tar.bz2"
CONTENTS="./keys/ ./bootstrap_node.sh ./images/ubuntu.tar.bz2 "
echo "Making $TARBALL containing <${CONTENTS}>..."
tar cvjf $TARBALL $CONTENTS 

#!/bin/bash

VERSION=$(uname -r)
BUILDDIR="/usr/src/linux-headers-${VERSION}"
cp /boot/config-${VERSION} $BUILDDIR
cd $BUILDDIR


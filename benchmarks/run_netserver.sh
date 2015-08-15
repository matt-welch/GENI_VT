#!/bin/bash

source ${GENI_HOME}/util/ids.sh
source ${GENI_HOME}/util/bash_colors.sh

BENCHDIR=${GENI_HOME}/benchmarks/

cd $BENCHDIR

./netserver -D -p 65432



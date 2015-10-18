#!/bin/bash

#BENCHDIR=/root/benchmarks/
#
#cd $BENCHDIR
#
# taskset the server to a core for more reliable results
taskset 0x2 ./netserver -p 65432


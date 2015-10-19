#!/bin/bash 
PORT="5201" # standard port 

# run standard iperf test 
./iperf3 -s -V -p $PORT --pidfile iperf.pid


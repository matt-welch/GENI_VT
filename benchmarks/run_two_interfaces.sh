#!/bin/bash

./run_netperf_fast.sh 192.168.42.245 | tee /root/results/3.18.20/netperf-remote-cont-br.dat 


./run_netperf_fast.sh 192.168.3.1 | tee /root/results/3.18.20/netperf-remote-cont-phy.dat 

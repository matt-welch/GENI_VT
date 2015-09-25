FILE="iperf-remotehost-phys.dat"; grep "Server output" -B 4 $FILE | grep datagrams -B 1 | grep Gbits/sec

#!/bin/bash
LOGDIR="${HOME}/results/logs"
echo "Collecting system logs to $LOGDIR"

hostname > $LOGDIR/hostname
cat /proc/cpuinfo > $LOGDIR/cpuinfo.log
/sbin/ifconfig > $LOGDIR/ifconfig.log
/usr/bin/lspci > $LOGDIR/lspci.log
service --status-all > $LOGDIR/services.log

NPROC=$(grep processor ~/results/logs/cpuinfo.log | tail -n 1 | cut -d ":" -f 2)
rm $LOGDIR/cpu_topo.log
for (( i = 0 ; i <= $NPROC ; i++ ))
do
    cat /sys/devices/system/cpu/cpu${i}/topology/thread_siblings_list >> $LOGDIR/cpu_topo.log
done

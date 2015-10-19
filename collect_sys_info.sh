#!/bin/bash
LOGDIR="/root/results/$(uname -r)"
mkdir -p $LOGDIR
echo "Collecting system logs to $LOGDIR"

dmesg | grep kvm > $LOGDIR/kvm.log
lsmod | grep kvm >> $LOGDIR/kvm.log
hostname > $LOGDIR/hostname.log
cat /proc/cpuinfo > $LOGDIR/cpuinfo.log
/sbin/ifconfig > $LOGDIR/ifconfig.log
/usr/bin/lspci > $LOGDIR/lspci.log
service --status-all > $LOGDIR/services.log
lsb_release -a > $LOGDIR/lsb_release.log
uname -a > $LOGDIR/uname.log
cat /proc/cmdline > $LOGDIR/cmdline.log
cat /proc/meminfo > $LOGDIR/meminfo.log
free -lh >> $LOGDIR/meminfo.log

NPROC=$(grep processor ~/results/logs/cpuinfo.log | tail -n 1 | cut -d ":" -f 2)
rm -f $LOGDIR/cpu_topo.log
for (( i=0 ; $i<="$NPROC" ; $i++ ))
do
    cat /sys/devices/system/cpu/cpu${i}/topology/thread_siblings_list >> $LOGDIR/cpu_topo.log
done

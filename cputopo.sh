LOGDIR="${HOME}/results/logs"
NPROC=$(grep processor ~/results/logs/cpuinfo.log | tail -n 1 | cut -d ":" -f 2)
rm $LOGDIR/cpu_topo.log

for (( i = 0 ; i <= $NPROC ; i++ ))
do
    cat /sys/devices/system/cpu/cpu${i}/topology/thread_siblings_list >> $LOGDIR/cpu_topo.log
done

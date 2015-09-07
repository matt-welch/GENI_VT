#!/bin/bash 

QEMU_PID=$(pgrep qemu)

TASKS=$(ls /proc/$QEMU_PID/task | grep -v $QEMU_PID)
TASK_ARR=($(echo ${TASKS}));

MASKS="1 2 3 4 1"
MASK_ARR=($(echo ${MASKS}));

for i in {0..4}
do
    taskset -cp ${MASK_ARR[$i]} ${TASK_ARR[$i]}
    taskset -p ${TASK_ARR[$i]}
done


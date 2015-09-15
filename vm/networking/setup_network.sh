#!/bin/bash 

source ../../util/bash_colors.sh
# 1) setup VF for control interface (eth1 VF) 
CONTROL_PF="08:00.1"
NUM_VFS=1
fcn_print_red "Enabling 1 VF for control interface ($CONTROL_PF)..."
./enable_vf_driver.sh $CONTROL_PF $NUM_VFS 

# 2) set up VF for data interface (p258p2 VF)
DATA_IF_VF="04:00.1"
fcn_print_red "Enabling 1 VF for data interface ($DATA_IF_VF)..."
./enable_vf_driver.sh $DATA_IF_VF $NUM_VFS 

# 3) set up PF for data interface (p258p1 PF)
DATA_IF_PF="04:00.0"
../unbind_driver.sh $DATA_IF_PF 

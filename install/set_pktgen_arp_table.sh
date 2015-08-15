#!/bin/bash

source ${GENI_HOME}/util/sys_vars.sh

ifconfig $IF1_NAME up $IF1_IP
arp -i $IF1_NAME -s $IF1_D_IP $IF1_D_MAC
ifconfig $IF2_NAME up $IF2_IP
arp -i $IF2_NAME -s $IF2_D_IP $IF2_D_MAC

arp -vn | grep --color -e $IF1_NAME -e $IF2_NAME -e $IF1_D_IP -e $IF2_D_IP


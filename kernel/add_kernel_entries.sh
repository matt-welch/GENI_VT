#!/bin/bash
sudo su root
cp ./09_RT_tuning /etc/grub.d/
cd /etc/grub.d
chown root:root 09_RT_tuning
chmod 755 09_RT_tuning
update-grub


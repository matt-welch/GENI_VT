#!/bin/bash
sudo cp ./09_RT_tuning /etc/grub.d/
cd /etc/grub.d
sudo chown root:root 09_RT_tuning
sudo chmod 755 09_RT_tuning
sudo update-grub


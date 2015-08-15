#!/bin/bash

# these interfaces will likely not be correct & should be adjusted for local system
#0000:06:00.0 '82599ES 10-Gigabit SFI/SFP+ Network Connection' if=eth10p1 drv=ixgbe unused=igb_uio *Active*
#  eth10p1   Link encap:Ethernet  HWaddr 00:1b:21:a2:72:48
#            inet addr:192.168.1.3  Bcast:192.168.1.255  Mask:255.255.255.0
#            inet6 addr: fe80::21b:21ff:fea2:7248/64 Scope:Link
#            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
#            RX packets:240890612 errors:0 dropped:5014153916 overruns:0 frame:0
#            TX packets:126686005 errors:0 dropped:0 overruns:0 carrier:0
#            collisions:0 txqueuelen:1000
#            RX bytes:14453446351 (14.4 GB)  TX bytes:7633083813 (7.6 GB)
IF1_PCI="06:00.0"
IF1_MAC="00:1b:21:a2:72:48"
IF1_NAME="eth9"
IF1_IP="192.168.1.3"
IF1_D_IP="192.168.1.2"
IF1_D_MAC="90:e2:ba:0e:4a:34"

#0000:06:00.1 '82599ES 10-Gigabit SFI/SFP+ Network Connection' if=eth10p2 drv=ixgbe unused=igb_uio *Active*
#  eth10p2   Link encap:Ethernet  HWaddr 00:1b:21:a2:72:49
#            inet addr:192.168.2.3  Bcast:192.168.2.255  Mask:255.255.255.0
#            inet6 addr: fe80::21b:21ff:fea2:7249/64 Scope:Link
#            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
#            RX packets:319490273 errors:0 dropped:5782238997 overruns:0 frame:0
#            TX packets:128110236 errors:0 dropped:0 overruns:0 carrier:0
#            collisions:0 txqueuelen:1000
#            RX bytes:30323773119 (30.3 GB)  TX bytes:7687999678 (7.6 GB)
IF2_PCI="06:00.1"
IF2_MAC="00:1b:21:a2:72:49"
IF2_NAME="eth10"
IF2_IP="192.168.2.3"
IF2_D_IP="192.168.2.2"
IF2_D_MAC="90:e2:ba:0e:4a:35"



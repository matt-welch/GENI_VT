sudo sysctl -w net.ipv4.ip_forward=1
# alternatively: 
# echo 1 > /proc/sys/net/ipv4/ip_forward

# to enable permanently, uncomment the line in /etc/sysctl.conf
# net.ipv4.ip_forward = 1


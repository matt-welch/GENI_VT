#!/bin/bash 
set -e  # set to error out if a variable is unset
if [ -z "$1" ] ; then 
    SERVER="192.168.42.242"
else
    SERVER="$1"
fi
PORT="5201" # standard port 
TARGET_BANDWIDTH="-b 20G"
# use the ablve flag to limit bandwidth (avoid when doing in-memory tx)
SERVERSTATS="--get-server-output" 
REPS=20
UDP_BUF_LEN=" -l 512" # useful for minimizing initial jitter 

# run iperf with udp
TEST="UDP Bandwidth, jitter"
echo "Running iperf3::${TEST} @ $(date): ${SERVER}:${PORT}, ($TARGET_BANDWIDTH) "
for (( i=0; i<"$REPS"; i++ )) ; do
    ./iperf3 -c $SERVER -p $PORT $SERVERSTATS -u $TARGET_BANDWIDTH $UDP_BUF_LEN
done

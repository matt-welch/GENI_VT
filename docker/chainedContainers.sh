#!/bin/bash
# enable errors if variable not defined
set -e 
# -e tells bash to exit on error, 
# -x tells it to print statements as they're exeuted with + prepended to line

DEBUG_MODE=true
DEBUG_PRINT_LEVEL=2
if [ "$DEBUG_MODE" -a "$DEBUG_PRINT_LEVEL" -ge 2 ] ; then 
    echo "  DEBUG: printing in eXecution mode (bash set -x)"
    set -x 
fi
# debug print levels: 0: minimal output, 1: some debug output, 2: LOTS of debug output

# base image info:
REPO="bench/network"
TAG="netbench"
MACROOT="de:ad:be:ef"
SUBNETROOT="192.168"
NUMCONT=4
if [ -n "$1" ] ; then 
    NUMCONT="$1"
fi
LINKMETHOD="brg"
if [ -n "$2" ] ; then 
    LINKMETHOD="$2"
fi
CONT_NUM_INIT=2
MAXCONT=$(( $NUMCONT + $CONT_NUM_INIT - 1 )) 
PORTINIT=65400

function debugPrint() {
    MSG=$1; PRINT_LEVEL=$2
    if [ "$DEBUG_MODE" == true  ] ; then 
        if [ "$PRINT_LEVEL" -le "$DEBUG_PRINT_LEVEL" ] ; then 
            echo "  DEBUG: $MSG"
        fi
    fi
}

function usage() {
    echo -e "Usage: \n $ $0 [NumContainers=4] [LinkType=brg]\n"
    exit
}

function dockerRun() {
    NAME=$1; PORT=$2;
    ENTRYPOINT="/root/netserver -p $PORT"
    ENTRYPOINT="/bin/bash"
    CONTID=$(docker run -d -it --net=none --name $NAME --privileged bench/network:netbench $ENTRYPOINT)
}

function dockerInspect(){
    NAME=$1; PARAM=$2;
    DATA=$(docker inspect --format=$PARAM $NAME)
    echo $DATA
}

function getPID(){
    CONTAINERNAME="$1"
    echo $( dockerInspect $CONTAINERNAME '{{.State.Pid}}' )
}

function dockerExec() {
    NAME=$1; CMD=$2;
    docker exec $NAME $CMD
}

function makeBridge() {
    THISBRNAME=$1; BRIPADDR=$2;
    echo "Creating bridge $THISBRNAME"
    brctl addbr $THISBRNAME
    ip link set $THISBRNAME up 
    ip addr add $BRIPADDR dev $THISBRNAME
    #ip addr show $THISBRNAME
}

function getMACAddr() {
    SN=$1; ID=$2; 
    SN=$(printf "%02d" $SN) # zero pad to 2 places
    ID=$(printf "%02d" $ID) # zero pad to 2 places
    echo "${MACROOT}:${SN}:${ID}"
}

function getIPAddr() {
    SN=$1; ID=$2; NETMASK=$3
    if [ -z "$NETMASK" ] ; then 
        NETMASK=24
    fi
    echo "${SUBNETROOT}.${SN}.${ID}/$NETMASK"
}

function getGateway() {
    SN=$1
    echo "192.168.${SN}.1"
}

function getSubnet() {
    SN=$1
    echo "192.168.${SN}.0/24"
}

function makeNSSymLink(){
    mkdir -p /var/run/netns
    MYPID="$1"
    NSLINK="/var/run/netns/$MYPID"
    # link the netns directories if not already present
    if [ -L "$NSLINK" ] ; then 
        echo "Note: $NSLINK already exists."
    else
        ln -s /proc/$MYPID/ns/net /var/run/netns/$MYPID
    fi
}

function doLinking() {
    MYPID=$1; MYDEV=$2; MYIP=$3; PeerIP=$4
    debugPrint "Linking netns $MYPID, $MYIP, $MYDEV ..." 1
    ip link set $MYDEV netns $MYPID
    debugPrint "CPID[$MYPID]: dev $MYDEV linked to netns" 1
    ip netns exec $MYPID ip addr add $MYIP dev $MYDEV
    debugPrint "CPID[$MYPID]: dev $MYDEV, IP $MYIP assigned" 1
    ip netns exec $MYPID ip link set $MYDEV up
    debugPrint "CPID[$MYPID]: dev $MYDEV, up" 1
    debugPrint "CPID[$MYPID]: Adding route from dev $MYDEV, to IP $PeerIP .... " 2
    ip netns exec $MYPID ip route add $PeerIP dev $MYDEV
    debugPrint "CPID[$MYPID]: route from dev $MYDEV, to IP $PeerIP assigned" 1
}

function linkCtr2Ctr() {
    C1NAME="$1"; C1IP="$2"
    C2NAME="$3"; C2IP="$4"
    C1PID=$( getPID $C1NAME )
    debugPrint "Container $C1NAME PID=$C1PID" 1
    C2PID=$( getPID $C2NAME )
    debugPrint "Container $C2NAME PID=$C2PID" 1
    
    makeNSSymLink $C1PID
    makeNSSymLink $C2PID
    
    # Create the "peer" interfaces and hand them out
    ip link add ethUS type veth peer name ethDS
    
    # attach interface to container 1
    doLinking $C1PID ethUS $C1IP $C2IP
    
    # attach interface to container 2
    doLinking $C2PID ethDS $C2IP $C1IP
}

function linkCtr2Brg() {
    CPID="$1"; BRNAME="$2"; IPADDR="$3"; 
    MACADDR="$4"; GUESTDEV="$5"; GATEWAY="$6"

    # Create a pair of "peer" interfaces A and B,
    # bind the A end to the bridge in host ns, and bring it up
    HOSTNSDEV="eth${BRNAME}${CPID}"
    debugPrint "Adding link-pair $HOSTNSDEV - veth" 1
    ip link add $HOSTNSDEV type veth peer name B
    debugPrint "Adding $HOSTNSDEV to $BRNAME " 1
    brctl addif $BRNAME $HOSTNSDEV
    ip link set $HOSTNSDEV up
    
    # Place B inside the container's network namespace,
    # rename to eth0, and activate it with a free IP
    if [ -z $GUESTDEV ] ; then 
        GUESTDEV=eth${BRNAME}
    fi
    ip link set B netns $CPID
    ip netns exec $CPID ip link set dev B name $GUESTDEV

    ip netns exec $CPID ip link set $GUESTDEV address $MACADDR
    ip netns exec $CPID ip link set $GUESTDEV up
    ip netns exec $CPID ip addr add $IPADDR dev $GUESTDEV
    if [ -n "$GATEWAY" ] ; then
        # link to gateway if it's provided
        ip netns exec $CPID ip route add default via $GATEWAY
    #else
    #    # TODO: is this correct???
    #    # ip netns exec $CPID ip route add $SUBNET dev eth0
    #    echo "Gateway: $GATEWAY"
    fi
    # TODO add routes to host netns
}

# Main program: 
debugPrint "$# arguments specified: \"$*\"" 2 
if [ "$#" -lt "2" ] ; then 
    usage
fi

mkdir -p /var/run/netns/

echo -e "$(date): Launching $NUMCONT chained containers...\n\n"

for (( CCOUNT=$CONT_NUM_INIT; CCOUNT<=$MAXCONT; CCOUNT++ )); do
    CNAME="netsrv${CCOUNT}"
    PORT=$(( $PORTINIT + $CCOUNT ))
    # downstream subnet is same as container number
    DSSUBNET=$CCOUNT

    # launch the container
    echo "Launching netbench container: $CNAME"
    dockerRun $CNAME $PORT
    # using --net=none
    MYPID=$(getPID $CNAME )

    # set up namespace
    makeNSSymLink $MYPID

    # get network addresses for downstream interface
    DSMAC=$(getMACAddr $DSSUBNET $CCOUNT )
    DSIP=$(getIPAddr $DSSUBNET $CCOUNT )  # all interfaces get the IP of their container #
    echo "Container $CNAME: netserver (PID=${MYPID}), @ DS-IP=${DSIP}:$PORT"

    if [ "$LINKMETHOD" = "brg" ] ; then 
        if [ "$CCOUNT" -lt "$MAXCONT" ] ; then 
            # Create a bridge to attach to downstream interface
            BRNAME="cbr$(printf "%02d" $DSSUBNET)"
            MYGW=$(getGateway $DSSUBNET )
            makeBridge $BRNAME $MYGW

            # attach container to bridge
            COMMAND="linkCtr2Brg ${MYPID} ${BRNAME} ${DSIP} ${DSMAC} eth2 ${MYGW}"
            echo "Linking container to downstream bridge: $COMMAND"
            eval $COMMAND 
        fi
    fi
done

echo -e "\n\nLinking containers to 'upstream' bridges or containers..."
## all containers and bridges have been created by now so link them together 
## link upstream containers to bridges
for (( CCOUNT=$CONT_NUM_INIT; CCOUNT<=$MAXCONT; CCOUNT++ )); do
    DSCNAME="netsrv${CCOUNT}"
    # upstream subnet is 1 less than container number
    USSUBNET=$(( $CCOUNT - 1 )) 
    USCTR=$USSUBNET 
    USCNAME="netsrv${USCTR}"

    # get container info
    MYPID=$(getPID $DSCNAME )

    # namespaces should already exist from previous loop

    # get network addresses for upstream interface
    USMAC=$(getMACAddr $USSUBNET $CCOUNT )
    USIP=$(getIPAddr $USSUBNET $CCOUNT 32 )  # all interfaces get the IP of their container
    DSIP=$(getIPAddr $USSUBNET $USCTR 32 ) # IP for upstream container
    MYROUTE=$(getSubnet $USSUBNET )
    echo "Container $DSCNAME: netserver (PID=${MYPID}), @ US-IP=${USIP}"

    if [ "$LINKMETHOD" = "brg" ] ; then 
        BRNAME="cbr$(printf "%02d" $USSUBNET)"
        if [ "$CCOUNT" -eq "$CONT_NUM_INIT" ] ; then 
            BRNAME="docker0"
        fi
        # attach container to upstream bridge
        COMMAND="linkCtr2Brg ${MYPID} ${BRNAME} ${USIP} ${USMAC} eth1"
        echo "Linking container to upstream bridge: $COMMAND"
        eval $COMMAND 
    else
        # link container directly to upstream neighbor if not first in line
        if [ "$CCOUNT" -gt "$CONT_NUM_INIT" ] ; then 
            COMMAND="linkCtr2Ctr ${USCNAME} ${DSIP} ${DSCNAME} ${USIP}"
            echo "Linking container to upstream container: $COMMAND"
            eval $COMMAND
        fi
    fi
done


#!/bin/bash
#The following low-level (i.e. not docker specific) network namespace tool commands can be used to transfer an interface from the host to a docker container:

function usage () {
    echo
    echo "$0 <Container name> <Host IF> [Guest IP/netmask]"
    echo "e.g. $0 silly_stallman eth7 192.168.2.2/24      "
    echo
    echo "Ethernet interfaces:"
    ifconfig -a | grep -e "Link" -e "inet addr" | grep -e "^\([a-z0-9]\)*" -e "\([0-9.]\)*" --color
    echo
    echo "docker images (running containers):"
    docker ps
    echo
    exit
}
IP_DEFAULT="192.168.2.2/24"
if (( "$#" < 2 )) ; then 
    usage
    exit
fi

if [ -z "$1" ] ; then 
    CONTAINER=foo # Name of the docker container
else
    CONTAINER=$1
fi

if [ -z "$2" ] ; then 
    echo "arg2=\"$2\""
    HOST_DEV=p258p1     # Name of the ethernet device on the host
else
    HOST_DEV=$2
fi
GUEST_DEV=$HOST_DEV   # Target name for the same device in the container

if [ -z "$3" ] ; then 
    ADDRESS_AND_NET=$(ip -f inet addr show $HOST_DEV | sed -n 's/^ *inet *\([.0-9]*\/[0-9]*\).*/\1/p')
    if [ -z $ADDRESS_AND_NET ] ; then
        echo "No IP address assigned to $HOST_DEV - assigning ${IP_DEFAULT}."
        ADDRESS_AND_NET=$IP_DEFAULT
    else
        echo "Assigning existing ip address: $ADDRESS_AND_NET "
    fi
else
    echo "Assigning user-specified IP addr - $3 - to $GUEST_DEV "
    ADDRESS_AND_NET="$3"
fi

CONTAINER_Id=$(docker inspect -f '{{ .Id }}' $CONTAINER)

# Next three lines hooks up the docker container's network namespace 
# such that the ip netns commands below will work
mkdir -p /var/run/netns
PID=$(docker inspect -f '{{.State.Pid}}' $CONTAINER)
ln -s /proc/$PID/ns/net /var/run/netns/$PID

# Move the ethernet device into the container. Leave out 
# the 'name $GUEST_DEV' bit to use an automatically assigned name in 
# the container
ip link set $HOST_DEV netns $PID name $GUEST_DEV

# Enter then network namespace ('ip netns exec $PID...') and configure
# the network device in the container
ip netns exec $PID ip addr add $ADDRESS_AND_NET dev $GUEST_DEV

# and bring it up.
ip netns exec $PID ip link set $GUEST_DEV up

# Delete netns link to prevent stale namespaces when the docker
# container is stopped
unlink /var/run/netns/$PID

# run docker exec to show the addresses of the container's interfaces
echo Docker ifconfig: 
docker exec $CONTAINER ifconfig -a


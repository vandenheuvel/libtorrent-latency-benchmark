#!/bin/bash
# containers.sh

STARTIP=100

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

if [ "$#" -ne 2 ]; then
    echo "Illegal number of arguments, give bridge name, number of seeders."
    exit 1
fi

BRIDGENAME=$1
NUMSEEDERS=$2
LEECHERNAME="Leecher0"
CONFIGOPTIONS="-d ubuntu -r xenial -a amd64"
LEECHERCONFIG="leecher.conf"
SEEDERCONFIG="seeder.conf"


seeder_container_names=()
for((index=0;index < $NUMSEEDERS;index++))
do
    seeder_container_names+=("Seeder$index")
done

echo "Destroying old containers..."
lxc-destroy --quiet -n $LEECHERNAME
for container in "${seeder_container_names[@]}"
do
    lxc-destroy --quiet -n $container
done

echo "Creating new containers..."

ip=$STARTIP
((ip++))
for container in "${seeder_container_names[@]}"
do
    echo "Creating and setting up $container..."
    cp $SEEDERCONFIG $container.conf
    echo -e "\nlxc.network.ipv4 = 192.168.1.$ip/24" >> $container.conf
    lxc-create --quiet --template download -n $container --config $container.conf -- $CONFIGOPTIONS
    lxc-start -n $container -F
    lxc-attach -n $container -- /mnt/dependencies.sh
    lxc-attach -n $container -- /usr/bin/python3 /mnt/seeder.py &
    ((ip++))
done

echo "Creating leecher..."
lxc-create --quiet --template download -n $LEECHERNAME --config leecher.conf -- $CONFIGOPTIONS
lxc-start -n $LEECHERNAME -F 
lxc-attach -n $LEECHERNAME -- /mnt/dependencies.sh
lxc-attach -n $LEECHERNAME -- /usr/bin/python3 /mnt/leecher.py $NUMSEEDERS 101

lxc-stop --quiet -n $LEECHERNAME
lxc-destroy --quiet -n $LEECHERNAME
for container in "${seeder_container_names[@]}"
do
    lxc-stop -n $container
    lxc-destroy --quiet -n $container
done





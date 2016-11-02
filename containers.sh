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

echo "Working from temporary directory $(pwd)/tmp..."
cd tmp

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
    echo -e "\nlxc.mount.entry = $(pwd)/seeder mnt none bind 0 0" >> $container.conf
    lxc-create --quiet --template download -n $container --config $container.conf -- $CONFIGOPTIONS
    lxc-start -n $container
    echo "Installing dependencies..."
    lxc-attach -n $container -- /mnt/install_dependencies.sh
    echo "Starting seeding..."
    lxc-attach -n $container -- /usr/bin/python3 /mnt/seeder.py &
    ((ip++))
done

echo "Creating leecher..."
echo -e "\nlxc.mount.entry = $(pwd)/leecher mnt none bind 0 0" >> $LEECHERCONFIG
lxc-create --quiet --template download -n $LEECHERNAME --config $LEECHERCONFIG -- $CONFIGOPTIONS
lxc-start -n $LEECHERNAME 
echo "Installing dependencies..."
lxc-attach -n $container -- /mnt/install_dependencies.sh
echo "Starting the test..."
lxc-attach -n $LEECHERNAME -- /usr/bin/python3 /mnt/leecher.py $NUMSEEDERS 101
echo "Test is done."

lxc-stop --quiet -n $LEECHERNAME
lxc-destroy --quiet -n $LEECHERNAME
for container in "${seeder_container_names[@]}"
do
    lxc-stop -n $container
    lxc-destroy --quiet -n $container
done

echo "Leaving temporary folder..."
cd ../

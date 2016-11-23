#!/bin/bash
# containers.sh

STARTIP=3
SUBNET=10.0.3.
DEPENDENCIES=python3-libtorrent

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

if [ "$#" -ne 5 ]; then
    echo "Illegal number of arguments, give number of seeders, test durations, latencyintervals and repetitions."
    exit 1
fi

NUMSEEDERS=$1
LEECHERNAME="Leecher0"
CONFIGOPTIONS="-d ubuntu -r xenial -a amd64"
LEECHERCONFIG="leecher.conf"
SEEDERCONFIG="seeder.conf"

RUNDURATION=$2
LATENCYINTERVALS=$3
REPETITIONS=$4
RESULTFILE=$5

echo "Working from temporary directory $(pwd)/tmp..."
cd tmp

seeder_container_names=()
for index in {1..6}
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
for container in "${seeder_container_names[@]}"
do
    echo "Creating and setting up $container..."
    cp $SEEDERCONFIG $container.conf
    echo -e "\nlxc.network.ipv4 = $SUBNET$ip/24" >> $container.conf
    echo -e "\nlxc.mount.entry = $(pwd)/seeder mnt none bind 0 0" >> $container.conf
    lxc-create --template download -n $container --config $container.conf -- $CONFIGOPTIONS
    lxc-start -n $container
    echo "Installing dependencies on $container..."
    lxc-attach -n $container -- ping -c1 8.8.8.8
    sleep 5
    lxc-attach -n $container -- apt-get update
    lxc-attach -n $container -- apt-get upgrade -y
    lxc-attach -n $container -- apt install $DEPENDENCIES -y
    echo "Starting seeding..."
    lxc-attach -n $container -- /usr/bin/python3 /mnt/seeder.py &
    ((ip++))
done

echo "Creating leecher..."
echo -e "\nlxc.mount.entry = $(pwd)/leecher mnt none bind 0 0" >> $LEECHERCONFIG
lxc-create --quiet --template download -n $LEECHERNAME --config $LEECHERCONFIG -- $CONFIGOPTIONS
lxc-start -n $LEECHERNAME 
echo "Installing dependencies..."
lxc-attach -n $LEECHERNAME -- ping -c1 8.8.8.8
sleep 5
lxc-attach -n $LEECHERNAME -- apt-get update
lxc-attach -n $LEECHERNAME -- apt-get upgrade -y
lxc-attach -n $LEECHERNAME -- apt install $DEPENDENCIES -y

echo "Starting the test..."
lxc-attach -n $LEECHERNAME -- /usr/bin/python3 /mnt/leecher.py $STARTIP $NUMSEEDERS $RUNDURATION $LATENCYINTERVALS $REPETITIONS $RESULTFILE
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


#!/bin/bash
# start.sh

<<DESCRIPTION 
    Setup and start the experiment from the physical host.
DESCRIPTION

# Check whether a network adapter is given
if [ "$#" -ne 1 ]
    then
    echo "Illegal number of arguments, give the network adapter."
    exit 1
fi

# Check whether the program is executed as root.
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

NETWORKDEVICE=$1
BRIDGE="br0"

echo "Enabling forwarding..."
sysctl net.ipv4.ip_forward=1
# For physical hosts with a wireless device
if [[ ${NETWORKDEVICE:0:1} == "w" ]] 
then
    iptables -t nat -A POSTROUTING -o $NETWORKDEVICE -j MASQUERADE
fi

echo "Setting up bridge..."
brctl addbr $BRIDGE
ifconfig $BRIDGE 10.0.0.1 

# Make temporary directory and adding files to this directory
FOLDERNAME="tmp/"
COPYFILES=("createPlot.py" "dependencies.sh" "host.conf" "leecher.conf" "leecher.py" "lxcControl.py" "main.py" "main.sh" "seeder.conf" "seeder.py")
mkdir $FOLDERNAME

for filename in "${COPYFILES[@]}"
do
    cp $filename $FOLDERNAME
done

echo "Creating host lxc..."
CONTAINER="hostContainer"
echo lxc.mount.entry = $(pwd)/$FOLDERNAME mnt none bind 0 0 >> $FOLDERNAME/host.conf
lxc-create -t download -n $CONTAINER -f $FOLDERNAME/host.conf -- -d ubuntu -r xenial -a amd64
echo "Starting $CONTAINER..."

echo -e "\nRunning main script in LXC host container...\n---\n---\n\n"
lxc-execute -n $CONTAINER -- mnt/main.sh
echo -e "\n---\n---\nDone executing main script in LXC host container.\n"

echo "Stopping LXC host..."
lxc-stop -n $CONTAINER
echo "Destroying LXC host..."
lxc-destroy -n $CONTAINER

echo "Removing temporary files and folders..."
rm -rf $FOLDERNAME

echo "Tearing down bridge..."
ifconfig $BRIDGE down
brctl delbr $BRIDGE 

echo "Disabling forwarding..."
sysctl net.ipv4.ip_forward=0

echo "Tests completed, results are in results/results.pdf"


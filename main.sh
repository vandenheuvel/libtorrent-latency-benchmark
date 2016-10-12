#!/bin/bash
bridgeName="br0"
pythonName="main.py"
numClients=1
numSeeders=4

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Removing bridge with name $bridgeName if one exists..."
ifconfig $bridgeName down
brctl delbr $bridgeName

echo "Creating and setting up bridge $bridgeName..."
brctl addbr $bridgeName
ifconfig $bridgeName up

echo "Running Python script $pythonName with parameters $bridgeName $numClients $numSeeders."
python3 $pythonName $bridgeName $numClients $numSeeders

echo "Removing bridge with name $bridgeName..."
ifconfig $bridgeName down
brctl delbr $bridgeName

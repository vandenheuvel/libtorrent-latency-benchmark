#!/bin/bash
bridgeName="br0"
mainScript="main.py"
numLeechers=1
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

echo "Creating temporary folder to conduct tests in..."


echo "Creating random file and torrent for the seeders to seed..."


echo "Running Python script $mainScript with parameters $bridgeName $numLeechers $numSeeders."
python3 $mainScript $bridgeName $numLeechers $numSeeders

echo "Removing bridge with name $bridgeName..."
ifconfig $bridgeName down
brctl delbr $bridgeName

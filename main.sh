#!/bin/bash
bridgeName="br0"
mainScript="main.py"
numLeechers=1
numSeeders=1
fileSize=32
dataFile="result.csv"
runDuration=30
latencyIntervals=20
tmpFolder="tmp"

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
mkdir $tmpFolder
mkdir $tmpFolder/seeder
mkdir $tmpFolder/leecher

cp seeder.py $tmpFolder/seeder
cp leecher.py $tmpFolder/leecher

echo "Creating random file and torrent for the seeders to seed..."
dd if=/dev/urandom of=tmp/seeder/random.file bs=1M count=$fileSize status=progress
#ctorrent...

echo "Running Python script $mainScript with parameters $bridgeName $numLeechers $numSeeders."
python3 $mainScript $bridgeName $numLeechers $numSeeders

echo "Copying results..."
mv $tmpFolder/leecher/$dataFile .

echo "Removing temporary folder..."
rm -rf $tmpFolder

echo "Showing plot..."
python3 createPlot.py $dataFile $runDuration $latencyIntervals

echo "Removing bridge with name $bridgeName..."
ifconfig $bridgeName down
brctl delbr $bridgeName

#!/bin/bash
BRIDGENAME="br0"
MAINSCRIPT="main.py"
NUMLEECHERS=1
NUMSEEDERS=1
FILESIZE=32
DATAFILE="result.csv"
RUNDURATION=30
LATENCYINTERVALS=20
TMPFOLDER="tmp/"
SEEDFOLDER=$TMPFOLDER"seeder/"
LEECHFOLDER=$TMPFOLDER"leecher/"
FILENAME="test.file"
TORRENTNAME="test.torrent"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Removing bridge with name $BRIDGENAME if one exists..."
ifconfig $BRIDGENAME down
brctl delbr $BRIDGENAME

echo "Creating and setting up bridge $BRIDGENAME..."
brctl addbr $BRIDGENAME
ifconfig $BRIDGENAME up

echo "Downloading ctorrent to create our torrent file"
apt install ctorrent -y
apt install python3-numpy -y
apt install python3-matplotlib -y

echo "Creating temporary folder to conduct tests in..."
mkdir $TMPFOLDER
mkdir $SEEDFOLDER
mkdir $LEECHFOLDER

echo "Copying leecher and seeder scripts to the correct folders..."
cp seeder.py $SEEDFOLDER 
cp leecher.py $LEECHFOLDER

echo "Creating random file and torrent for the seeders to seed..."
dd if=/dev/urandom of=$SEEDFOLDER$FILENAME bs=1M count=$FILESIZE status=progress
ctorrent -t -u 127.0.0.1 -s $SEEDFOLDER$TORRENTNAME $SEEDFOLDER$FILENAME
cp $SEEDFOLDER$TORRENTNAME $LEECHFOLDER$TORRENTNAME

echo "Running Python script $MAINSCRIPT with parameters $BRIDGENAME $NUMLEECHERS $NUMSEEDERS..."
python3 $MAINSCRIPT $BRIDGENAME $NUMLEECHERS $NUMSEEDERS

echo "Copying results..."
mv $LEECHFOLDER$DATAFILE .

echo "Removing temporary folder..."
rm -rf $TMPFOLDER

echo "Showing plot..."
python3 createPlot.py $DATAFILE $RUNDURATION $LATENCYINTERVALS

echo "Removing bridge with name $BRIDGENAME..."
ifconfig $BRIDGENAME down
brctl delbr $BRIDGENAME

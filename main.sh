#!/bin/bash
# main.sh

TMPFOLDER="tmp/"
SEEDFOLDER=$TMPFOLDER"seeder/"
LEECHFOLDER=$TMPFOLDER"leecher/"

DEVICE="enp0s3"
BRIDGENAME="br0"
MAINSCRIPT="main.py"
DATAFILE="result.csv"

FILENAME="test.file"
TORRENTNAME="test.torrent"

NUMLEECHERS=1
NUMSEEDERS=1
FILESIZE=32
RUNDURATION=30
LATENCYINTERVALS=20

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Removing possible previous folder..."
rm -rf $TMPFOLDER

echo "Creating temporary folder to conduct tests in..."
mkdir $TMPFOLDER
mkdir $SEEDFOLDER
mkdir $LEECHFOLDER

echo "Copying leecher and seeder scripts to the correct folders..."
cp {seeder.conf,leecher.conf} $TMPFOLDER
cp seeder.py $SEEDFOLDER
cp leecher.py $LEECHFOLDER

echo "Creating random file of $FILESIZE MB and torrent for the seeders to seed... This might take a while."
dd if=/dev/urandom of=$SEEDFOLDER$FILENAME bs=1M count=$FILESIZE status=progress
ctorrent -t -u 127.0.0.1 -s $SEEDFOLDER$TORRENTNAME $SEEDFOLDER$FILENAME
cp $SEEDFOLDER$TORRENTNAME $LEECHFOLDER$TORRENTNAME

echo -e "\n\nRunning container.sh..."
./containers.sh $NUMSEEDERS
echo -e "Done running container.sh.\n\n"


echo "Copying data from temporary folder..."
cp $LEECHFOLDER$DATAFILE $DATAFILE

exit

echo "Removing temporary folder..."
rm -rf $TMPFOLDER

echo "Creating plot..."
python3 create_plot.py $DATAFILE $RUNDURATION $LATENCYINTERVALS


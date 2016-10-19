#!/bin/bash
# main.sh

WORKINGDIR="/mnt"
TMPFOLDER="tmp/"
SEEDFOLDER=$TMPFOLDER"seeder/"
LEECHFOLDER=$TMPFOLDER"leecher/"

BRIDGENAME="lxcbr0"
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

echo "Setting DNS..."
echo -e "nameserver 8.8.8.8\nnameserver 208.67.222.222\n" > /etc/resolv.conf

echo "Setting PATH variable..."
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

echo "Downloading dependencies..."
apt-get update -qq > /dev/null
DEPENDENCIES=("bridge-utils" "ctorrent" "python3-numpy" "python3-matplotlib" "lxc")
for package in "${DEPENDENCIES[@]}"
do
    apt-get -qq install $package -y > /dev/null
done

echo "Removing bridge with name $BRIDGENAME regardless of whether one exists..."
ifconfig $BRIDGENAME down
brctl delbr $BRIDGENAME

echo "Creating and setting up bridge $BRIDGENAME..."
brctl addbr $BRIDGENAME
ifconfig $BRIDGENAME up

echo "Working from $WORKINGDIR. Creating temporary folder to conduct tests in..."
cd $WORKINGDIR
mkdir $TMPFOLDER
mkdir $SEEDFOLDER
mkdir $LEECHFOLDER

echo "Copying leecher and seeder scripts to the correct folders..."
cp seeder.py $SEEDFOLDER 
cp leecher.py $LEECHFOLDER
cp dependencies.sh $SEEDFOLDER
cp dependencies.sh $LEECHFOLDER

echo "Creating random file of $FILESIZE MB and torrent for the seeders to seed... This might take a while."
dd if=/dev/urandom of=$SEEDFOLDER$FILENAME bs=1M count=$FILESIZE status=progress
ctorrent -t -u 127.0.0.1 -s $SEEDFOLDER$TORRENTNAME $SEEDFOLDER$FILENAME
cp $SEEDFOLDER$TORRENTNAME $LEECHFOLDER$TORRENTNAME

echo "Downloading dependencies for seeders and leechers..."
./dependencies.sh -d

echo -e "\n---\n---\nRunning Python script $MAINSCRIPT with parameters $BRIDGENAME $NUMLEECHERS $NUMSEEDERS...\n\n"
python3 $MAINSCRIPT $BRIDGENAME $NUMLEECHERS $NUMSEEDERS
echo -e "\n\nDone running Python script $MAINSCRIPT.\n---\n---\n"

echo "Copying results..."
mv $LEECHFOLDER$DATAFILE .

echo "Removing temporary folder..."
rm -rf $TMPFOLDER

echo "Showing plot..."
python3 createPlot.py $DATAFILE $RUNDURATION $LATENCYINTERVALS

echo "Removing bridge with name $BRIDGENAME..."
ifconfig $BRIDGENAME down
brctl delbr $BRIDGENAME

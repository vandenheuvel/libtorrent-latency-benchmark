#!/bin/bash
# main.sh

TMPFOLDER="tmp/"
SEEDFOLDER=$TMPFOLDER"seeder/"
LEECHFOLDER=$TMPFOLDER"leecher/"

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

echo "Downloading dependencies..."
apt-get update > /dev/null
DEPENDENCIES=("bridge-utils" "ctorrent" "lxc" "cgroupfs-mount" "apt-rdepends")
for package in "${DEPENDENCIES[@]}"
do
    echo "Getting package $package..."
    DEBIAN_FRONTEND=noninteractive apt-get install $package -y > /dev/null
done

echo "Setting some DNS servers..."
echo "nameserver 8.8.8.8\nnameserver8.8.4.4\n" > /etc/resolv.conf

echo "Creating and setting up bridge $BRIDGENAME..."
brctl addbr $BRIDGENAME
ifconfig $BRIDGENAME up
ifconfig $BRIDGENAME 192.168.1.99

echo "Creating temporary folder to conduct tests in..."
mkdir $TMPFOLDER
mkdir $SEEDFOLDER
mkdir $LEECHFOLDER

echo "Copying leecher and seeder scripts to the correct folders..."
cp {seeder.conf,leecher.conf} $TMPFOLDER
cp install_dependencies.sh $SEEDFOLDER
cp install_dependencies.sh $LEECHFOLDER
cp seeder.py $SEEDFOLDER
cp leecher.py $LEECHFOLDER

echo "Creating random file of $FILESIZE MB and torrent for the seeders to seed... This might take a while."
dd if=/dev/urandom of=$SEEDFOLDER$FILENAME bs=1M count=$FILESIZE status=progress
ctorrent -t -u 127.0.0.1 -s $SEEDFOLDER$TORRENTNAME $SEEDFOLDER$FILENAME
cp $SEEDFOLDER$TORRENTNAME $LEECHFOLDER$TORRENTNAME

echo "Downloading dependencies..."
./download_dependencies.sh

echo -e "\n\nRunning container.sh..."
./containers.sh $BRIDGENAME $NUMSEEDERS
echo -e "Done running container.sh.\n\n"


#mv $LEECHFOLDER$DATAFILE $DATAFILE
echo "Removing temporary folder..."
rm -rf $TMPFOLDER

echo "Creating plot..."
#python3 create_plot.py $DATAFILE $RUNDURATION $LATENCYINTERVALS

echo "Removing bridge with name $BRIDGENAME..."
ifconfig $BRIDGENAME down
brctl delbr $BRIDGENAME


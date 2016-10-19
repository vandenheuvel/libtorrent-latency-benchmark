#!/bin/bash
downloadPackages=("python3-libtorrent")

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Either downloading only or downloading and installing dependencies.
if [ $1 = download ]; then
    echo "Downloading dependencies..."
    shellCommand="apt-get -d install"
else
    echo "Installing dependencies..."
    shellCommand="apt-get install"
fi

# For each package in downloadPackages, use the shellCommand.
for package in $downloadPackages
do
    echo "Downloading package $package..."
    $shellCommand $package -y
done


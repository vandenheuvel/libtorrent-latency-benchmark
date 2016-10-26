#!/bin/bash

downloadPackages=("python3-libtorrent" "python3-numpy")

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi


# For each package in downloadPackages, using the option given as the argument
for package in "${downloadPackages[@]}"
do
    DEBIAN_FRONTEND=noninteractive apt-get $1 install $package -y > /dev/null
done


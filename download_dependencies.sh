#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

download_packages=("python3-libtorrent" "python3-numpy")

# For each package in downloadPackages, using the option given as the argument
for package in "${download_packages[@]}"
do
    for dependency in $(apt-rdepends python3-numpy | grep -v "^ ")
    do
        DEBIAN_FRONTEND=noninteractive apt-get -d install $package -y > /dev/null
    done
done


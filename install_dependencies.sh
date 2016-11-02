#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

install_packages=("python3-libtorrent" "python3-numpy")

for package in "${install_packages[@]}"
do
    dpkg --install /var/cache/apt/archives/$package*.deb
done


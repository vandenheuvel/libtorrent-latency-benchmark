#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

STARTDIR=$(pwd)

cd /var/cache/apt/archives
dpkg --install *.deb 

cd $STARTDIR

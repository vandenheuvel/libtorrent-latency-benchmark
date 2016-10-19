#!/usr/bin/python3
# main.py

"""
Runs the experiment from inside the LXC.
"""

import lxcControl as lxcctl
import os
import sys
import lxc
import subprocess


startIP = 100

# Specifies some of the options used for the creation of the different LXC container types. 
seederOptions = {"dist": "ubuntu", "release": "xenial", "arch": "amd64"} 
leecherOptions = {"dist": "ubuntu", "release": "xenial", "arch": "amd64"} 
 
# Specifies the location of the config files of the different LXC container types. 
leecherConfDir = "./leecher.conf" 
seederConfDir = "./seeder.conf"


# Check for superuser privileges.
if not os.geteuid() == 0:
    sys.exit("Run as root.")

# Check whether enough arguments are given.
if not len(sys.argv) == 4:
    sys.exit("Give three arguments: bridgeName, amount of leechers, amount of seeders.")

print("Creating names for " + sys.argv[2] + " leecher and for " + sys.argv[3] + " seeder containers...")
leecherNames = ["ClientContainer" + str(x + 1) for x in range(int(sys.argv[2]))]
seederNames = ["SeederContainer" + str(x + 1) for x in range(int(sys.argv[3]))]

# Create new containers and start them.
print("Deleting existing containers by the same names as created, if existing...")
lxcctl.destroyExisting(leecherNames)
lxcctl.destroyExisting(seederNames)

print("Create new leecher and seeder containers...")
leecherContainers = lxcctl.createContainers(leecherNames, leecherOptions)
seederContainers = lxcctl.createContainers(seederNames, seederOptions)

print("Adding config to created containers...")
lxcctl.loadConfig(leecherContainers, leecherConfDir, startIP)
lxcctl.loadConfig(seederContainers, seederConfDir, (startIP + int(sys.argv[2])))

print("Stopping the currently running containers...")
lxcctl.stopContainers(leecherContainers)
lxcctl.stopContainers(seederContainers)

print("Destroying the existing containers...")
lxcctl.destroyExisting(leecherNames)
lxcctl.destroyExisting(seederNames)

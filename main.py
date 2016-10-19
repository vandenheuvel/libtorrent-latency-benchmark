#!/usr/bin/python3

import lxcControl as lxcctl
import config
import os
import sys
import lxc
import subprocess

startIP = 100

# Check for superuser privileges.
if not os.geteuid() == 0:
    sys.exit("Run as root.")

# Check whether enough arguments are given.
if not len(sys.argv) == 4:
    sys.exit("Give three arguments: bridgeName, amount of leechers, amount of seeders.")

print("Creating names for " + sys.argv[2] + " leecher and for " + sys.argv[3] + " seeder containers...")
leecherNames = ["ClientContainer" + str(x + 1) for x in range(int(sys.argv[2]))]
seederNames = ["SeederContainer" + str(x + 1) for x in range(int(sys.argv[3]))]

# Create fresh containers and start them.
print("Deleting existing containers by the same names as created, if existing...")
lxcctl.destroyExisting(leecherNames)
lxcctl.destroyExisting(seederNames)

print("Create new leecher and seeder containers...")
leecherContainers = lxcctl.createContainers(leecherNames, config.leecherOptions)
seederContainers = lxcctl.createContainers(seederNames, config.seederOptions)

print("Adding config to created containers...")
lxcctl.loadConfig(leecherContainers, config.leecherConfDir, startIP)
lxcctl.loadConfig(seederContainers, config.seederConfDir, (startIP + int(sys.argv[2])))

print("Stopping the currently running containers...")
lxcctl.stopContainers(leecherContainers)
lxcctl.stopContainers(seederContainers)

print("Destroying the existing containers...")
lxcctl.destroyExisting(leecherNames)
lxcctl.destroyExisting(seederNames)

#!/usr/bin/python3

import lxcControl as lxcctl
import config
import os
import sys
import lxc
import subprocess

# Check for superuser privileges.
if not os.geteuid() == 0:
    sys.exit("Run as root.")

# Check whether enough arguments are given.
if not len(sys.argv) == 4:
    sys.exit("Give three arguments: bridgeName, amount of clients, amount of seeders.")

print("Creating names for " + sys.argv[2] + " client and for " + sys.argv[3] + " seeder containers...")
clientNames = ["ClientContainer" + str(x + 1) for x in range(int(sys.argv[2]))]
seederNames = ["SeederContainer" + str(x + 1) for x in range(int(sys.argv[3]))]

# Create fresh containers and start them.
print("Deleting existing containers by the same names as created, if existing...")
lxcctl.destroyExisting(clientNames)
lxcctl.destroyExisting(seederNames)

print("Create new client and seeder containers...")
clientContainers = lxcctl.createContainers(clientNames, config.clientOptions)
seederContainers = lxcctl.createContainers(seederNames, config.serverOptions)

print("Adding config to created containers...")
lxcctl.loadConfig(clientContainers, config.clientConfDir)
lxcctl.loadConfig(seederContainers, config.hostConfDir)

print("Stopping the currently running containers...")
lxcctl.stopContainers(clientContainers)
lxcctl.stopContainers(seederContainers)

print("Destroying the existing containers...")
lxcctl.destroyExisting(clientNames)
lxcctl.destroyExisting(seederNames)

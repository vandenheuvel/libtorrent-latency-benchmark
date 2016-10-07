#!/usr/bin/python3

import bridgeControl as brctl
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
if not len(sys.argv) == 3:
    sys.exit("Give two unused names for the containers.")

# Create a fresh bridge.
brctl.delbr("br0");
brctl.addbr("br0");

# Create fresh containers and start them.
lxcctl.destroyExisting(sys.argv[1:3])
(server, client) = lxcctl.createTemporary([(sys.argv[1], config.serverOptions), (sys.argv[2], config.clientOptions)])
if not lxcctl.startContainers([server, client]):
    print("Failed to start a container, exiting.", file=sys.stderr)
    exit(1)

# Install scripts to both the server and the client container.
lxcctl.installScripts([(server, config.bindDir), (client, config.bindDir)])

# Finish the test, removing both the containers and the bridge.
lxcctl.stopContainers([server, client])
lxcctl.destroyExisting(sys.argv[1:3])
brctl.delbr("br0");

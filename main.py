#!/usr/bin/python3

import os
import sys
import lxc
import subprocess

serverOptions = {"dist": "ubuntu", "release": "xenial", "arch": "amd64"}
clientOptions = {"dist": "ubuntu", "release": "xenial", "arch": "amd64"}
#serverOptions = {"dist": "ubuntu", "release": "xenial", "arch": "amd64", "config": "client.conf"}
#clientOptions = {"dist": "ubuntu", "release": "xenial", "arch": "amd64", "config": "client.conf"}
bindDir = "/bind/"


def destroyExisting(containerNames):
    for containerName in containerNames:
        print("Destroying container \"", containerName, "\"...", sep="")
        container = lxc.Container(containerName)
        if container.defined:
            if container.running:
                if not stopContainers([container]):
                    print("Failed to shutdown container \"", containerName, "\". Exiting...")
                    exit(1)
            if not container.destroy():
                print("Failed to destroy container \"", containerName, "\".", sep="", file=sys.stderr)
                print("There may still be some containers left on your system. Exiting...")
                exit(1)

def createTemporary(toCreate):
    createdContainers = []
    for containerName, containerOptions in toCreate:
        print("Creating container \"", containerName, "\"...", sep="")
        container = lxc.Container(containerName)
        if container.defined:
            print("Container \"", containerName, "\" already exists.", sep="", file=sys.stderr)
            createdContainers.append(container)
            continue
        if not container.create("download", lxc.LXC_CREATE_QUIET, containerOptions):
            print("Failed to create container \"", containerName, "\".", sep="")
            continue
        createdContainers.append(container)
    return createdContainers

def startContainers(containers):
    success = True
    for container in containers:
        if not container.start():
            print("Failed to start container.", file=sys.stderr)
            success = False
        print("Container state: %s" % container.state)
    return success

def installScripts(toBind):
    for (container, directory) in toBind:
        print("Binding ", os.getcwd() + directory, " to ", container, "...", sep="")

        

def benchmark():
    print("Benchmarking...")

def stopContainers(containers):
    success = True
    for container in containers:
        print("Shutting down", container)
        if not container.shutdown(15):
            print("Clean shutdown failed, forcicng.", file=sys.stderr)
            if not container.stop():
                print("Failed to stop container.", file=sys.stderr)
                success = False
    return success



# Check for superuser privileges
if not os.geteuid() == 0:
    sys.exit("Run as root.")

if not len(sys.argv) == 3:
    sys.exit("Give two unused names for the containers.")

destroyExisting(sys.argv[1:3])
(server, client) = createTemporary([(sys.argv[1], serverOptions), (sys.argv[2], clientOptions)])
if not startContainers([server, client]):
    print("Failed to start a container, exiting.", file=sys.stderr)
    exit(1)
installScripts([(server, bindDir), (client, bindDir)])
benchmark()
stopContainers([server, client])
destroyExisting(sys.argv[1:3])


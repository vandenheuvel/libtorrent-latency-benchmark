import lxc
import sys
import config
import os


# Destroy containers with given names contained within containerNames.
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

# Create containers with given names contained within containerNames.
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

# Start all the containers in the list containers.
def startContainers(containers):
    success = True
    for container in containers:
        if not container.start():
            print("Failed to start container.", file=sys.stderr)
            success = False
        print("Container state: %s" % container.state)
    return success

# Bind the directory to the given containers within toBind.
def installScripts(toBind):
    for (container, directory) in toBind:
        print("Binding ", os.getcwd() + directory, " to ", container, "...", sep="")

# Stop all containers which are contained within the list containers.
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




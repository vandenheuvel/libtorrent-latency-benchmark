import os

# Delete the bridge with the given bridgeName
def delbr(bridgeName):
    print("Deleting bridge \"", bridgeName, "\"...", sep="")
    os.system("ifconfig " + bridgeName + " down")
    os.system("brctl delbr " + bridgeName)

# Add the bridge with the given bridgeName
def addbr(bridgeName):
    print("Creating bridge \"", bridgeName, "\"...", sep="")
    os.system("brctl addbr " + bridgeName)
    os.system("ifconfig " + bridgeName + " up")

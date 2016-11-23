#!/usr/bin/env python3
# leecher.py
 
"""
This script tests the downloading speed from the given IPS of different latencies.
This is done by netem to emulate the latency.
The results are then saved to a .csv file
"""

import os
import sys
import time
import libtorrent as lt

# Give the starting IP and the number of IPs
numVars = 6
if len(sys.argv) != numVars + 1:
    print("This script requires arguments, the starting IP, the number of IPs, testduration, latencyintervalsize, amount of repetitions and name of result file .")

startIP = int(sys.argv[1])
numIPs = int(sys.argv[2])

# Creation of variables used within the function
downloadFolder = '/mnt/'
torrentFolder = '/mnt/'
resultFolder = '/mnt/'
resultName = sys.argv[6]
torrentName = 'test.torrent'
fileName = "test.file"
networkDevice = 'eth0'
measureEvery = .1
latencyInterval = int(sys.argv[4])
numIntervals = int(sys.argv[5])
totalTime = int(sys.argv[3])
iterations = round(totalTime / measureEvery)

# Creation of both the latencies to be used and the save array for the speeds
latencies = [latencyInterval * x for x in range(numIntervals)]
speeds = [[0 for x in range(iterations)] for y in latencies]

for index, latency in enumerate(latencies):
    print('\nNow testing with latency', latency, '...')

    # Adding latency to the network device
    os.system('sudo tc qdisc add dev ' + networkDevice + ' root netem delay ' + str(latency) + 'ms')

    # Open the torrent and start downloading
    torrent = open(torrentFolder + torrentName, 'rb')
    ses = lt.session()
    ses.listen_on(6881, 6891)

    e = lt.bdecode(torrent.read())
    info = lt.torrent_info(e)

    params = { 'save_path': downloadFolder, 'storage_mode': lt.storage_mode_t.storage_mode_sparse, 'ti': info }
    h = ses.add_torrent(params)
    
    # Editing settings for the tests.
    settings = ses.get_settings()

    ses.set_settings(settings)
    # Add the peers to the torrent
    for ipAddress in range(startIP, (startIP + numIPs + 1)):
        h.connect_peer(('192.168.1.' + str(ipAddress), 6881), 0x01)

    # Save data for the amount of iterations into speed
    for i in range(iterations):
        sys.stdout.write('\r%.2f%%' % (100 * i / iterations))
        s = h.status()

        state_str = ['queued', 'checking', 'downloading metadata', 'downloading', 'finished', 'seeding', 'allocating']
        speeds[index][i] = s.download_rate / 1000
        time.sleep(measureEvery)
        if s.is_seeding:
            break
    sys.stdout.write('\n')

    # Remove latency settings and the (partially) downloaded torrent.
    os.system('sudo tc qdisc del dev ' + networkDevice + ' root netem')
    os.system('rm ' + downloadFolder + fileName)

# Write the speeds array to a .csv file
with open(resultFolder + resultName, 'w') as f:
    for row in speeds:
        for number in row[:-1]:
            f.write(str(number))
            f.write(",")
        f.write(str(row[-1]))
        f.write("\n")


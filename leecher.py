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
import requests
#from twisted.internet import selectreactor
#selectreactor.install()
from twisted.internet import reactor, task
import threading

def main():
    iterations = 300

    # Creation of variables used within the function
    downloadFolder = '/home/user/'
    torrentFolder = '/home/user/'
    resultFolder = '/home/user/'
    torrentName = 'test.torrent'
    fileName = "test.file"
    networkDevice = 'eth0'
    measureEvery = 1
    totalTime = 300

    # Creation of both the latencies to be used and the save array for the speeds
    speeds = []

    # Open the torrent and start downloading
    torrent = open(torrentFolder + torrentName, 'rb')
    ses = lt.session()
    ses.listen_on(6881, 6891)

    e = lt.bdecode(torrent.read())
    info = lt.torrent_info(e)

    params = { 'save_path': downloadFolder, 'storage_mode': lt.storage_mode_t.storage_mode_sparse, 'ti': info }
    h = ses.add_torrent(params)

    #print(requests.get("http://10.0.3.248:8000/").status_code)

    # Get the settings for the tests.
    #settings = ses.get_settings()
    ## Changing the settings - experimental #
    #settings['allow_multiple_connections_per_ip'] = True
    #settings['disable_hash_checks'] = True
    #settings['low_prio_disk'] = False
    #settings['strict_end_game_mode'] = False
    #settings['smooth_connects'] = False
    #settings['connections_limit'] = 500
    #settings['recv_socket_buffer_size'] = os_default
    #settings['send_socket_buffer_size'] = os_default 
    # Set the settings
    #ses.set_settings(settings)

    # Add the peer to the torrent
    h.connect_peer(('10.0.3.248', 6881), 0x01)

    # Save data for the amount of iterations into speed
    def printSpeed(h, speeds):
        s = h.status()
        speeds.append(s.download_rate / 1000)
        print(speeds[-1], s.state)

    #threading.Thread(target=printSpeed, args=(h, speeds)).start()
    l = task.LoopingCall(printSpeed, h, speeds)
    l.start(1)

reactor.callWhenRunning(main)
reactor.run()

# Write the speeds array to a .csv file
with open('poll.csv', 'w') as f:
    for speed in speeds:
        f.write(str(speed) + ',')

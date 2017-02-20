# seeder.py

"""This script seeds the specified torrent file."""

import time
import libtorrent as lt
#from twisted.internet import selectreactor 
#selectreactor.install()
from twisted.internet import reactor, task

def main():
    # Choose from which directory to seed, and where the torrent is stored
    downloadFolder = '/home/user/'
    torrentFolder = '/home/user/'
    torrentName = 'test.torrent'

    # Read the torrent file
    torrent = open(torrentFolder + torrentName, 'rb')

    # Start a libtorrent session
    ses = lt.session()

    # Listen on default port range
    ses.listen_on(6881, 6891)

    e = lt.bdecode(torrent.read())
    info = lt.torrent_info(e)

    # Add the torrent and start seeding
    params = { 'save_path': downloadFolder, 'storage_mode': lt.storage_mode_t.storage_mode_sparse, 'ti': info }
    h = ses.add_torrent(params)

    def printSpeed(h):
        s = h.status()
        print(s.download_rate)
        print(s.state)

    l = task.LoopingCall(printSpeed, h)
    l.start(1)

reactor.callWhenRunning(main)
reactor.run()

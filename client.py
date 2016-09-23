# Retrieved on September 23st, 2016 from http://libtorrent.org/python_binding.html
# Arvid Norberg is listed as the original author of the article.

import libtorrent as lt
import time

torrent = open("test.torrent", 'rb')

ses = lt.session()
ses.listen_on(6881, 6891)

e = lt.bdecode(torrent.read())
info = lt.torrent_info(e)

params = { 'save_path': '../Downloads', 'storage_mode': lt.storage_mode_t.storage_mode_sparse, 'ti': info }
h = ses.add_torrent(params)

s = h.status()
while (not s.is_seeding):
    s = h.status()

    state_str = ['queued', 'checking', 'downloading metadata', 'downloading', 'finished', 'seeding', 'allocating']
    print('%.2f%% complete (down: %.1f kb/s up: %.1f kB/s peers: %d) %s' %  (s.progress * 100, s.download_rate / 1000, s.upload_rate / 1000, s.num_peers, state_str[s.state]))

    time.sleep(1)

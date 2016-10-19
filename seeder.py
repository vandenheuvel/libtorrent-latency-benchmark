# Initial version retrieved on September 23st, 2016 from http://libtorrent.org/python_binding.html
# Arvid Norberg is listed as the original author of the article.

import libtorrent as lt

downloadFolder = './'
torrentFolder = './'
torrentName = 'test.torrent'

torrent = open(torrentFolder + torrentName, 'rb')

ses = lt.session()
ses.listen_on(6881, 6891)

e = lt.bdecode(torrent.read())
info = lt.torrent_info(e)

params = { 'save_path': downloadFolder, 'storage_mode': lt.storage_mode_t.storage_mode_sparse, 'ti': info }
h = ses.add_torrent(params)


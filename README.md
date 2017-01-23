# libtorrent-latency-benchmark

This is a tool which can be used to test throughput between libtorrent instancesrunning on linux containers. We've used this setup only on Ubuntu.

## Dependencies

Make sure to have the `lxc`, `ctorrent`, `python3-numpy` and `python3-matplotlib` and their dependencies installed. Inside the LXC's we use libtorrent via the `python3-libtorrent` python bindings.

## Summary of results

So far, we've been able to get a consistent throughput of ~ 200 MB / s on a single seeder, single leecher setup. With 200 ms of latency, this decreases to ~ 15 MB / s for the same single seeder, single leecher setup. We've been able to increase this to ~ 35 MB / s by increasing the `default` and `max` parameters of the `net.ipv4.tcp_rmem` and `net.ipv4.tcp_wmem` parameters. For some graphs, see [https://github.com/Tribler/tribler/issues/2620](this) github issue.

